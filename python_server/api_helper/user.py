import re
from warnings import resetwarnings
from flask import request
from flask.helpers import make_response
from werkzeug.wrappers import Response, ResponseStreamMixin
from flask_jwt_extended.utils import get_jwt
from flask_restx import Resource, Namespace
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token, create_refresh_token
import bcrypt
from bson.objectid import ObjectId
from datetime import datetime, timedelta

from controller.image import save_image, get_image
from controller.filter import check_duplicate, check_jwt
from controller.etc import fix_index

import mongo as mongo

mongodb = mongo.MongoHelper()

User = Namespace(name="user", description="유저 관련 API")
Token = Namespace(name="token", description="access토큰 재발급 API")

Activity = Namespace(name="activity", description="유저 활동 관련 API")


@Token.route('')
class TokenControl(Resource):
    @jwt_required(refresh=True)
    def get(self):  # refresh 로 access 발급
        user_id = get_jwt_identity()
        refresh_token = (mongodb.find_one(query={"_id": user_id}, collection_name="user"))["refreshToken"]
        
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

        result1 = mongodb.insert_one(data=data, collection_name="block_list")  # result1은 _id
        print(result1)

        result2 = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set": {"refreshToken": ""}})  # unset으로 아예 삭제할 수도 있음

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

        if check_id:
            result = check_duplicate(key="_id", target=check_id)

        if check_email:
            result = check_duplicate(key="information.email", target=check_email)

        if check_nickname:
            result = check_duplicate(key="subInformation.nickname", target=check_nickname)

        if not result:
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

            # 순서 고정
            information = fix_index(target=user_info["information"], key=["name", "email", "birth", "type"])
            sub_information = fix_index(target=user_info["subInformation"], key=["nickname", "profileImage"])
            activity = fix_index(target=user_info["activity"], key=["posts", "replies", "likes", "reports", "bookmarks"])

            if sub_information["profileImage"]:
                sub_information["profileImage"] = save_image(sub_information["profileImage"], "user")

            real_user_info = {"_id": user_info["_id"],
                              "password": user_info["password"],
                              "information": information,
                              "subInformation": sub_information,
                              "activity": activity,
                              "calendar": "",
                              "message": {
                                  "send": [],
                                  "receive": []
                                }
                              }

            mongodb.insert_one(data=real_user_info, collection_name="user")  # 데이터베이스에 저장

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
        final_new_password = new_encrypted_password.decode('utf-8')  # db 저장시에는 디코드

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
                        "_id": None,
                        "nickname": None,
                        "type": None,
                        "profileImage": None
                    }
                }
                post_change_result = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=board_type, modify={"$set": alert_delete})

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
                        "_id": None,
                        "nickname": None,
                        "type": None,
                        "profileImage": None
                    }
                }
                reply_change_result = mongodb.update_one(query={"_id": ObjectId(reply_id)}, collection_name=board_type, modify={"$set": alert_delete})

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
        

        else:
            # 비밀번호 일치한 경우
            access_token = create_access_token(identity=request_info["_id"], expires_delta=False)
            refresh_token = create_refresh_token(identity=request_info["_id"], expires_delta=False)

            add_refresh_token = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set": {"refreshToken": refresh_token}})
            if add_refresh_token.raw_result["n"] != 1:
                response_result = make_response({"queryStatus": "add token fail"}, 500)
                return response_result

            # 회원정보 조회
            user_info = mongodb.find_one(query={"_id": user_id}, collection_name="user")

            # 순서 고정
            information = fix_index(target=user_info["information"], key=["name", "email", "birth", "type"])
            sub_information = fix_index(target=user_info["subInformation"], key=["nickname", "profileImage"])
            activity = fix_index(target=user_info["activity"], key=["posts", "replies", "likes", "reports", "bookmarks"])

            sub_information["profileImage"] = get_image(sub_information["profileImage"], "user")

            real_user_info = {"_id": user_info["_id"],
                                "password": user_info["password"],
                                "information": information,
                                "subInformation": sub_information,
                                "activity": activity}

            response_result = make_response({
                       "accessToken": access_token,
                       "refreshToken": refresh_token,
                       "user": real_user_info
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

        # 순서 고정
        information = fix_index(target=user_info["information"], key=["name", "email", "birth", "type"])
        sub_information = fix_index(target=user_info["subInformation"], key=["nickname", "profileImage"])
        activity = fix_index(target=user_info["activity"], key=["posts", "replies", "likes", "reports", "bookmarks"])

        sub_information["profileImage"] = get_image(sub_information["profileImage"], "user")

        real_user_info = {"_id": user_info["_id"],
                          "password": user_info["password"],
                          "information": information,
                          "subInformation": sub_information,
                          "activity": activity,
                          "calendar": user_info["calendar"]}

        response_result = make_response({"user": real_user_info}, 200)
        
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
        del (request_info["activity"])

        result = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set": request_info})

        if result.raw_result["n"] == 1:
            modified_user = mongodb.find_one(query={"_id": user_id},
                                             collection_name="user")
            modified_user["password"] = "비밀번호"
            
            response_result = make_response(modified_user, 200)

        else:
            response_result = make_response({"queryStatus": "infomation update fail"}, 500)
        
        return response_result


@Activity.route("/<string:activity_type>")
class ActivityControl(Resource):
    """
    공감, 스크랩, 댓글, 작성글
    """

    @jwt_required()
    def get(self, activity_type):  # 회원활동 탭에서 보여지는 정보 (게시글 리스트)
        """
        사용자 활동과 관련된 게시글 보여주기
        """
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        user_info = mongodb.find_one(query={"_id": user_id}, collection_name="user")

        target_activity = user_info["activity"][activity_type]

        if not target_activity:  # 타겟 activity 가 없는 경우
            # 리스트로 이루어진 리스트  "likes" : [["board_type", "content_id"], ["board_type", "content_id"]
            response_result = make_response({
                       "{}List".format(activity_type): None
                   }, 200)

        else:  # 타켓 activity 가 있는 경우
            post_list = []
            for post in target_activity:
                board_type = post[0] + "_board"
                post_id = post[1]

                result = mongodb.find_one(query={"_id": ObjectId(post_id)}, collection_name=board_type)
                if result:  # 해당 게시글이 있는 경우(삭제되지 않은 경우)
                    result["_id"] = str(result["_id"])
                    result["date"] = (result["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")

                    if result not in post_list:  # 중복 피하기 위함
                        post_list.append(result)  # 제일 뒤로 추가함 => 결국 위치 동일
                else:  # 삭제된 경우
                    continue

            post_list.sort(key=lambda x: x["_id"], reverse=True)
            response_result = make_response({
                       "{}List".format(activity_type): post_list
                   }, 200)

        return response_result