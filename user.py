from flask import request
from flask_restx import Resource, Api, Namespace, fields
import jwt
import bcrypt
from pymongo import encryption
from bson.objectid import ObjectId


import mongo

from .utils import SECRET_KEY, ALGORITHM

mongodb = mongo.MongoHelper()

User = Namespace(name="user", description="유저 관련 API")
Activity = Namespace(name="activity", description="유저 활동 관련 API")



@User.route('/register')
class AuthRegister(Resource):
    """
    (아이디, 닉네임)중복확인, 회원가입, 비밀번호변경, 회원탈퇴
    { 
        "_id": string   
        "password": string
        “information”: { 
                "name": string
                "email": string
                "birth": string
                "type": string
        }, 
        “subinfo”: { 
            "nickname": string
            "profile_image": string(
        }, 
        “activity”: { 
            "posts": list
            "reply": list
            "likes": list
            "report": list
        } 
    }
    """

    def get(self):
        """
        입력한 id의 중복여부를 확인합니다
        http://0.0.0.0:5000/user/register?id=hello
        http://0.0.0.0:5000/user/register?nickname=hello
        """
        check_id = request.args.get("id")
        check_email = request.args.get("email")
        check_nickname = request.args.get("nickname")
        
        if check_id:
            if mongodb.find_one(query={"_id": check_id}, collection_name="user"):
                return {
                    "message": "The ID already exist"
                }, 500
            else :
                return{
                    "message": "Possible"
                }, 200

        elif check_email:
            if mongodb.find_one(query={"subinfo": {"email": check_email}}, collection_name="user"):
                return {
                    "message": "The email already exist"
                }, 500
            else :
                return{
                    "message": "Possible"
                }, 200

        elif check_nickname:
            if mongodb.find_one(query={"subinfo": {"nickname": check_nickname}}, collection_name="user"):
                return {
                    "message": "The nickname already exist"
                }, 500
            else :
                return{
                    "message": "Possible"
                }, 200
        

    def post(self):
        """
        회원가입을 완료합니다.
        """
        user_info = request.get_json()

        encrypted_password = bcrypt.hashpw(str(user_info["password"]).encode("utf-8"), bcrypt.gensalt())  # 비밀번호를 암호화
        user_info["password"] = encrypted_password.decode("utf-8")  # 이를 또 UTF-8 방식으로 디코딩하여, str 객체로 데이터 베이스에 저장
        mongodb.insert_one(user_info, collection_name="user")  # 데이터베이스에 저장
        token_encoded = jwt.encode({'_id': user_info["_id"]}, SECRET_KEY, ALGORITHM)  # user 의 id로 토큰 생성(고유한 정보가 id 이므로)

        return {
            'Authorization': token_encoded,
            "message": 'Register Success'
        }, 200


    def put(self):
        """
        비밀번호를 변경합니다 
        비밀번호 변경 클릭 -> 아이디 비밀번호 한 번 더 확인 -> 새로운 비밀번호 입력 후 변경
        """
        header = request.headers.get('Authorization')
        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)

        new_password = request.get_json()
        new_encrypted_password = bcrypt.hashpw(str(new_password["password"]).encode("utf-8"), bcrypt.gensalt())
        new_password["password"] = new_encrypted_password.decode('utf-8')  # db 저장시에는 디코드

        result = mongodb.update_one(query={"_id": token_decoded["_id"]}, collection_name="user", modify={"$set": new_password})

        if result.raw_result["n"] == 1:
            return {"query_status" : "비밀번호 변경을 완료했습니다"}
        else:
            return {"query_status": "해당 id의 사용자를 찾을 수 없습니다."}, 500

        
    def delete(self):
        """
        회원정보를 삭제합니다(회원탈퇴)
        회원탈퇴 클릭 -> 아이디 비밀번호 한 번 더 확인 -> 회원탈퇴
        """
        header = request.headers.get('Authorization')
        # header 에 token_encoded 를 넣어서 request
        if header is None: 
            return {"message": "Please Login"}, 404

        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)  # {'id':실제 id} 딕셔너리형태로 돌려줌
        result = mongodb.delete_one(query={"_id": token_decoded["_id"]}, collection_name="user")

        if result.raw_result["n"] == 1:
            return{"query _status": "success"}
        else :
            return {"query_status": "해당 id의 사용자를 찾을 수 없습니다."}, 500
    


@User.route('/login')
class AuthLogin(Resource):
    """
    로그인, 회원정보, 회원정보수정
    """
    def post(self):  # 로그인
        """
        입력한 id, password 일치여부를 검사합니다(로그인 시, 회원탈퇴 위한 아이디, 비밀번호 확인 시)
        """
        sign_info = request.get_json()  # 사용자가 로그인 시 입력한 아이디, 비밀번호
        input_password = sign_info["password"]
        user_info = mongodb.find_one(query={"_id": sign_info["_id"]}, collection_name="user")  # 동일한 아이디불러오기
        
        if not user_info:
            # 해당 아이디가 없는 경우
            return {
                "message": "Users Not Found"
            }, 404

        elif not bcrypt.checkpw(input_password.encode("utf-8"), user_info["password"].encode("utf-8")):
            # 비밀번호가 일치하지 않는 경우
            return {
                "message": "Wrong Password"
            }, 500

        else:
            # 비밀번호 일치한 경우
            token_encoded = jwt.encode({'_id': user_info["_id"]}, SECRET_KEY, ALGORITHM)
            return {
                'Authorization': token_encoded, 
                "message" : 'Login Success'
            }, 200


    def get(self):  # 회원정보조회
        """
        회원정보를 조회합니다.
        """
        header = request.headers.get('Authorization')
        # header 에 token_encoded 를 넣어서 request
        if header is None: 
            return {"message": "Please Login"}, 404
        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)  # {'id':실제 id} 딕셔너리형태로 돌려줌
        user_info = mongodb.find_one(query={"_id": token_decoded["_id"]}, collection_name="user", projection_key={"password": 0})
        
        return user_info,200
    

    def put(self):  # 회원정보수정
        """
        회원정보를 수정합니다
        """
        header = request.headers.get('Authorization')
        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)  # 인코드된 토큰 받아서 디코드함

        user_info = request.get_json()
        result = mongodb.update_one(query={"_id": token_decoded["_id"]}, collection_name="user", modify={"$set": user_info})

        if result.raw_result["n"] == 1:
            modified_user = mongodb.find_one(query={"id": token_decoded["id"]},
                                             collection_name="user",
                                             projection_key={"password":0})

            return modified_user
        else:

            return {"query_status": "해당 id의 사용자를 찾을 수 없습니다"}, 500



@Activity.route('')
class ActivityControl(Resource):
    """
    공감, 스크랩, 댓글, 작성글
    """
    def put(self):  # 활동 추가
        """
        사용자 활동 추가하기
        """
        header = request.headers.get("Authorization")  # 이 회원의 활동정보 변경

        if header is None: 
            return {"message": "Please Login"}, 404

        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)

        new_activity_info = request.get_json()  
        """
        {
            "likes" : ["board_type", "content_id"]
        } 
        """

        user_activity = mongodb.find_one(query={"_id": token_decoded["_id"]}, collection_name="user", projection_key={"activity": 1})
        """
        {
         "activity" : {
           "likes" : [["board_type", "content_id"], ["board_type", "content_id"]],
           "posts" : [[], []]
        }
        """

        for key in new_activity_info:
            specific_activity = user_activity["activity"][key]
            specific_activity.append(new_activity_info[key])  # insert : 제일 앞으로 추가함
        
        result = mongodb.update_one(query={"_id": token_decoded["_id"]}, collection_name="user", modify={"$set" : user_activity})

        if result.raw_result["n"] == 1:
            return {"query_status": "활동을 저장했습니다"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500
    

    def delete(self):  # 활동 제거(활동 취소 시, 게시글 삭제 시)
        """
        사용자 활동 지우기
        """
        header = request.headers.get("Authorization")  # 이 회원의 활동정보 변경

        if header is None: 
            return {"message": "Please Login"}, 404

        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)

        new_activity_info = request.get_json()  
        """
        {
            "like" : ["board_type", "content_id"]
        } 
        """
        
        user_activity = mongodb.find_one(query={"_id": token_decoded["_id"]}, collection_name="user", projection_key={"activity": 1})
        """
        {
         "activity" : {
           "likes" : [["board_type", "content_id"], ["board_type", "content_id"]],
           "posts" : [[], []]
        }
        """

        for key in new_activity_info:  # key : "likes" ,"posts"
            content_id = new_activity_info[key][1]
            specific_activity = user_activity["activity"][key]  # "likes"의 구체적인 내용 : 리스트로 이루어진 리스트
            for post in specific_activity:  # post는 개별 게시글
                if content_id in post:
                    specific_activity.remove(post)

        result = mongodb.update_one(query={"_id": token_decoded["_id"]}, collection_name="user", modify={"$set" : user_activity})

        if result.raw_result["ok"] == 1:
            return {"query_status": "활동을 제거했습니다"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500


    def get(self):  # 회원활동 탭에서 보여지는 정보 (게시글 리스트)
        """
        사용자 활동과 관련된 게시글 보여주기
        /activity?activity-type=likes
        /activity?activity-type=posts
        """
        header = request.headers.get("Authorization")

        if header is None: 
            return {"message": "Please Login"}, 404

        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)  # {'id':실제 id} 딕셔너리형태로 돌려줌

        activity_type = request.args.get("activity-type")       

        activity_info = mongodb.find_one(query={"_id": token_decoded["_id"]}, collection_name="user", projection_key={"activity":1})
        # activity_info를 통해서 공감, 스크랩, 댓글, 게시글 별 content_id와 board_type을 얻을 수 있음
        # 이거 가지고 프론트가 get을 요청하거나 백에서 그거 까지 해서 주거나

        specific_activity =  activity_info["activity"][activity_type]
        # 리스트로 이루어진 리스트  "like" : [["board_type", "content_id"], ["board_type", "content_id"]

        post_list = []
        for post in specific_activity:
            try :
                board_type = post[0]+"_board"
                content_id = post[1]

                result = mongodb.find_one(query={"_id": ObjectId(content_id)},collection_name=board_type)
                result["_id"] = str(result["_id"])

                post_list.append(result)  # 제일 뒤로 추가함 => 결국 위치 동일

                post_list.sort(key=lambda x:x["_id"], reverse=True )
            
            except TypeError:
                pass
        
        return {
            "post_list" : post_list
        }
