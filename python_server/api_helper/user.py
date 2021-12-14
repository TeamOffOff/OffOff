from flask import request, render_template
from flask.helpers import make_response
from pymongo.message import delete
from flask_jwt_extended.utils import get_jwt
from flask_restx import Resource, Namespace
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token, create_refresh_token
import bcrypt
from bson.objectid import ObjectId
from datetime import datetime, timedelta
from api_helper.utils  import GMAIL_ID, SEND_MAIL_API
from controller.email import send_email
from controller.image import delete_image, save_image, get_image
from controller.filter import check_duplicate, check_jwt

import mongo as mongo

mongodb = mongo.MongoHelper()

User = Namespace(name="user", description="유저 관련 API")
Token = Namespace(name="token", description="access토큰 재발급 API")
Verify = Namespace(name="verify", description="이메일 확인을 위한 API")



@Verify.route('')
class VerifyControl(Resource):
    def get(self):
        verify_email = request.args.get("email")
        result = mongodb.update_one(
            query={"information.email": verify_email}, 
            collection_name="user", 
            modify={"$set": {"verifyEmail": True}})

        if result.raw_result["n"] == 1:  # 잘 변경됨
            print("잘 변경 됨")
            # 메일 보내기
            send_email(GMAIL_ID, "", "{}변경 완료".format(verify_email))

        else:
            print('변경 안 됨')
            # 메일 보내기
            send_email(GMAIL_ID, "", "{}변경 실패".format(verify_email))
        
        return make_response(render_template('email.html'))
        

# db 초기화했는데, 그 전에 만들어뒀던 token으로 활동가능한 문제
@Token.route('')
class TokenControl(Resource):
    @jwt_required(refresh=True)
    def get(self):  # refresh 로 access 발급
        user_id = get_jwt_identity()
        refresh_token = (mongodb.find_one(
            query={"_id": user_id}, 
            collection_name="user"))["refreshToken"]
        
        if not refresh_token:  # refresh token이 탈취되어서 db에서 삭제한 경우
            response_result = make_response({
                       "queryStatus": "refresh token was taken"
                   }, 403)

        else:
            delta = timedelta(minutes=1)
            access_token = create_access_token(identity=user_id, expires_delta=delta)

            response_result = make_response({
                    "accessToken": access_token,
                    "queryStatus": 'success'
                }, 200)

        return response_result

    @jwt_required()
    def delete(self):  # access or refresh 가 탈취된 경우 or 로그아웃하는 경우 => 현재 access blocklist에 추가 + 현재 refresh db 에서 삭제

        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        print("user_id: ", user_id)
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        jti = get_jwt()["jti"]
        print(jti)

        # createdAt이 block_list의 index임
        data = {
            "_id": jti,
            "createdAt": datetime.utcnow()
        }

        result1 = mongodb.insert_one(
            data=data, 
            collection_name="block_list")  # result1은 _id
        print(result1)

        result2 = mongodb.update_one(
            query={"_id": user_id}, 
            collection_name="user", 
            modify={"$set": {"refreshToken": ""}})  # unset으로 아예 삭제할 수도 있음

        if not result1:
            response_result = make_response({
                       "queryStatus": "add accessToken fail"
                   }, 500)
            return response_result

        if result2.raw_result["n"] == 0:
            response_result = make_response({
                       "queryStatus": "delete refreshToken fail"
                   }, 500)
            return response_result

        response_result = make_response({
                   "queryStatus": "success"
               }, 200)

        return response_result


@User.route('/register')
class AuthRegister(Resource):
    """
    (아이디, 닉네임)중복확인, 회원가입, 비밀번호변경, 회원탈퇴
    """

    def get(self):  # 중복확인
        check_id = request.args.get("id")
        check_email = request.args.get("email")
        check_nickname = request.args.get("nickname")
        
        # UnboundLocalError: local variable 'response_result' referenced before assignment
        response_result = "" 

        if check_id:
            response_result = check_duplicate(key="_id", target=check_id)

        if check_email:
            response_result = check_duplicate(key="information.email", target=check_email)

        if check_nickname:
            response_result = check_duplicate(key="subInformation.nickname", target=check_nickname)

        if not response_result:
            response_result = make_response({"queryStatus": "possible"}, 200)

        return response_result

    def post(self):  # 회원가입
        """
        회원가입을 완료합니다.
        """
        user_info = request.get_json()

        # 중복확인
        if check_duplicate(key="_id", target=user_info["_id"]):
            response_result = make_response({
                       "queryStatus": "id already exist"
                   }, 409)
            return response_result
        if check_duplicate(key="information.email", target=user_info["information"]["email"]):
            response_result = make_response({
                       "queryStatus": "email already exist"
                   }, 409)
            return response_result
        if check_duplicate(key="subInformation.nickname", target=user_info["subInformation"]["nickname"]):
            response_result = make_response({
                       "queryStatus": "nickname already exist"
                   }, 409)
            return response_result

        # 비밀번호를 암호화: 암호화할 때는 string이면 안 되고 byte여야 해서 encode
        encrypted_password = bcrypt.hashpw(str(user_info["password"]).encode("utf-8"), bcrypt.gensalt())

        # 이를 또 UTF-8 방식으로 디코딩하여, str 객체로 데이터 베이스에 저장
        user_info["password"] = encrypted_password.decode("utf-8")

        try:
            print("비밀번호 암호화 후 : ", user_info)

            if user_info["subInformation"]["profileImage"]:  # profile이미지 설정 시
                user_info["subInformation"]["profileImage"] = save_image(user_info["subInformation"]["profileImage"], "user")
            
            # db에 포함시킬 field 추가
            user_info["calendar"] = ""  # 캘린더
            user_info["message"] = {  # 메시지
                "send": [],
                "receive":[]
            }
            user_info["verifyEmail"] = False  # 이메일 인증여부

            # 인증 이메일 보낼 주소
            r_email = user_info["information"]["email"]

            # 데이터베이스에 저장
            mongodb.insert_one(data=user_info, collection_name="user")  

            # 메일 보내기
            send_email(r_email, SEND_MAIL_API+r_email, "감사합니다")

            # response
            response_result = make_response({"queryStatus": 'success'}, 200)

            return response_result

        # 타입에러 발생하는 경우 찾고, try-excpet 가 아니라 if-else 문으로 바꾸기
        except TypeError:
            return TypeError

    @jwt_required()
    def put(self):
        print("시작")
        """
        비밀번호를 변경합니다 
        비밀번호 변경 클릭 -> 아이디 비밀번호 한 번 더 확인 -> 새로운 비밀번호 입력 후 변경
        """
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        new_password = (request.get_json())["password"]
        new_encrypted_password = bcrypt.hashpw(str(new_password).encode("utf-8"), bcrypt.gensalt())
        final_new_password = new_encrypted_password.decode('utf-8')  # db 저장시에는 디코드 --> 이렇게 해야 salt 에러 안 뜸

        result = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set": {"password": final_new_password}})

        if result.raw_result["n"] == 1:
            response_result = make_response({"queryStatus": "success"}, 200)
        else:
            response_result = make_response({"queryStatus": "password update fail"}, 500)
        
        return response_result


    @jwt_required()
    def delete(self):
        """
        회원정보를 삭제합니다(회원탈퇴)
        회원탈퇴 클릭 -> 아이디 비밀번호 한 번 더 확인 -> 회원탈퇴
        """
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        user_info = mongodb.find_one(query={"_id": user_id}, collection_name="user")

        # 활동 알수없음으로 바꾸기
        print("author을 알 수 없음으로 바꾸는 과정 진입")
        activity = user_info["activity"]
        posts = activity["posts"]
        replies = activity["replies"]
        print("게시글 작성: ", posts)
        print("댓글 or 대댓글 작성:", replies)

        # 게시글 알 수 없음
        if posts:
            print("작성한 게시물이 있는 경우")
            for post in posts:
                board_type = post["boardType"] + "_board"
                post_id = post["postId"]
                print(board_type, post_id)
                alert_delete = {
                    "author": {
                        "_id": "",
                        "nickname": "알 수 없음",
                        "profileImage": [],
                        "type": ""
                    }
                }

                # author = null로 변경
                post_change_result = mongodb.update_one(
                    query={"_id": ObjectId(post_id)}, 
                    collection_name=board_type, 
                    modify={"$set": alert_delete})

                if post_change_result.raw_result["n"] == 0:
                    response_result = make_response({"queryStatus": "author information change fail"}, 500)
                    return response_result
        
        # 댓글 알 수 없음
        if replies:
            print("작성한 댓글이 있는 경우")
            for reply in replies:
                board_type = reply["boardType"] + "_board_reply"
                reply_id = reply["replyId"]
                print(board_type, reply_id)
                alert_delete = {
                    "author": {
                        "_id": "",
                        "nickname": "알 수 없음",
                        "profileImage": [],
                        "type": ""
                    }
                }
                if not ("_" in reply_id): # 댓글인 경우
                    reply_change_result = mongodb.update_one(
                        query={"_id": ObjectId(reply_id)}, 
                        collection_name=board_type, 
                        modify={"$set": alert_delete})
                else : # childrenReply를 어떻게 할 것인가!!!!
                    parent_reply_id = reply_id.split("_")[0]

                    reply_change_result = mongodb.update_one(
                        query={"_id": ObjectId(parent_reply_id)}, 
                        collection_name=board_type, 
                        modify={"$set": {"childrenReplies.$[elem].author": 
                        {"_id": "", 
                        "nickname":"알 수 없음", 
                        "profileImage": [], 
                        "type":""}
                        }}, 
                        array_filters=[{"elem._id":reply_id}])

                if reply_change_result.raw_result["n"] == 0:
                    response_result = make_response({"queryStatus": "author information change fail"}, 500)
                    return response_result
        
        # 캘린더 삭제하기
        calendar_id = user_info["calendar"]
        if calendar_id:  # 캘린더 아이디 있는 경우에만 (캘린더 안 만들고 탈퇴하는 경우 발생하는 오류 방지)
            result = mongodb.delete_one(query={"_id":calendar_id}, collection_name="calendar")

            if result.raw_result["n"] == 0:
                response_result = make_response({"queryStatus": "calendar delete fail"}, 500)
                return response_result

        # profileImage 삭제
        user_image = mongodb.find_one(query={"_id": user_id}, collection_name="user")["subInformation"]["profileImage"]
        delete_image(user_image, "user")

        # 탈퇴하기
        result = mongodb.delete_one(query={"_id": user_id}, collection_name="user")

        if result.raw_result["n"] == 1:
            response_result = make_response({"queryStatus": "success"}, 200)
        
        else:
            response_result = make_response({"queryStatus": "user delete fail"}, 500)
        
        return response_result


@User.route('/login')
class AuthLogin(Resource):
    """
    로그인, 회원정보, 회원정보수정
    """

    def post(self):  # 로그인
        """
        입력한 id, password 일치여부를 검사합니다(로그인 시, 회원탈퇴 위한 아이디, 비밀번호 확인 시)
        """
        request_info = request.get_json()  # 사용자가 로그인 시 입력한 아이디, 비밀번호
        user_id = request_info["_id"]
        user_pw = request_info["password"]

        user_info = mongodb.find_one(query={"_id": user_id}, collection_name="user")  # 동일한 아이디불러오기

        if not user_info:
            # 해당 아이디가 없는 경우
            response_result = make_response({
                       "queryStatus": "not exist"
                   }, 403)

        elif not bcrypt.checkpw((user_pw).encode("utf-8"), user_info["password"].encode("utf-8")):
            # 비밀번호가 일치하지 않는 경우
            response_result = make_response({
                       "queryStatus": "wrong password"
                   }, 401)
        
        elif not user_info["verifyEmail"]:
            # 이메일 인증을 하지 않은 경우
            response_result = make_response({
                "queryStatus": "not verify email"
            }, 400)

        else:
            # 위의 조건을 다 통과한 경우
            access_token = create_access_token(identity=request_info["_id"], expires_delta=False)
            refresh_token = create_refresh_token(identity=request_info["_id"], expires_delta=False)

            add_refresh_token = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set": {"refreshToken": refresh_token}})
            if add_refresh_token.raw_result["n"] != 1:
                response_result = make_response({"queryStatus": "add token fail"}, 500)
                return response_result

            # 회원정보 조회
            user_info = mongodb.find_one(query={"_id": user_id}, collection_name="user")
            print(user_info["subInformation"]["profileImage"])

            user_info["subInformation"]["profileImage"] = get_image(user_info["subInformation"]["profileImage"], "user", "200")

            response_result = make_response({
                       "accessToken": access_token,
                       "refreshToken": refresh_token,
                       "user": user_info
                   }, 200)

        return response_result

    @jwt_required()  # jwt 보냈는지, 만료된 건 아닌지
    def get(self):  # 회원정보조회
        """
        회원정보를 조회합니다.
        """

        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        user_info = mongodb.find_one(query={"_id": user_id}, collection_name="user")

        del user_info["activity"]
        del user_info["password"]
        del user_info["calendar"]
        del user_info["message"]
        del user_info["verifyEmail"]
        del user_info["refreshToken"]

        user_info["subInformation"]["profileImage"] = get_image(user_info["subInformation"]["profileImage"], "user", "origin")

        response_result = make_response({"user": user_info}, 200)
        
        return response_result

    @jwt_required()
    def put(self):  # 회원정보수정 => 순서고정 코드 추가 고려
        """
        회원정보를 수정합니다
        """

        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result
        

        request_info = request.get_json()

        print(user_id, request_info["_id"])

        if (user_id != request_info["_id"]):  # 자기 아이디가 아닌 경우
            response_result = make_response({"queryStatus": "Wrong User"}, 403)
            return response_result

        del (request_info["activity"])
        del (request_info["_id"]) # 혹시나 _id가 다르면 에러남 (_id는 변화시킬 수 있는 값이 아니므로)
        del (request_info["password"])  # 이거 안 하고 회원정보 수정하면 비밀번호 쪽이 이상해짐

        result = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set": request_info})

        if result.raw_result["n"] == 1:
            modified_user = mongodb.find_one(query={"_id": user_id},
                                             collection_name="user")
            modified_user["password"] = "비밀번호"
            
            response_result = make_response(modified_user, 200)

        else:
            response_result = make_response({"queryStatus": "infomation update fail"}, 500)
        
        return response_result


