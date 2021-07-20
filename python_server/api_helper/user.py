from flask import request
from flask_restx import Resource, Api, Namespace, fields
import jwt
import bcrypt
from pymongo import encryption

import mongo

from .utils import SECRET_KEY, ALGORITHM

mongodb = mongo.MongoHelper()

Auth = Namespace(name="Auth", description="유저 관련 API")


@Auth.route('/register')
class AuthRegister(Resource):
    """
    중복확인, 회원가입, 비밀번호변경, 회원탈퇴
    """
    def get(self):
        """
        입력한 id의 중복여부를 확인합니다
        """
        check_id = request.get_json()
        if mongodb.find_one(query={"id": check_id["id"]}, collection_name="user"):
            return {
                "message": "The ID already exist"
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
        token_encoded = jwt.encode({'id': user_info["id"]}, SECRET_KEY, ALGORITHM)  # user 의 id로 토큰 생성(고유한 정보가 id 이므로)

        return {
            'Authorization': token_encoded,
            "message": 'Register Success'
        }, 200
    

    def put(self):
        """
        비밀번호를 변경합니다 
        비밀번호 변경 클릭 -> 아이디 비밀번호 한 번 더 확인(/Auth/login) -> 새로운 비밀번호 입력 후 변경(/Auth/register)
        """
        header = request.headers.get('Authorization')
        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)

        new_password = request.get_json()
        new_encrypted_password = bcrypt.hashpw(str(new_password["password"]).encode("utf-8"), bcrypt.gensalt())
        new_password["password"] = new_encrypted_password.decode('utf-8')  # db저장시에는 디코드

        result = mongodb.update_one(query={"id": token_decoded["id"]}, collection_name="user", modify={"$set": new_password})

        if result.raw_result["n"] == 1:
            return {"query_status" : "비밀번호 변경을 완료했습니다"}
        else:
            return {"query_status": "해당 id의 사용자를 찾을 수 없습니다."}, 500

        
    def delete(self):
        """
        회원정보를 삭제합니다(회원탈퇴)
        회원탈퇴 클릭 -> 아이디 비밀번호 한 번 더 확인(/Auth/login) -> 회원탈퇴(/Auth/register)
        """
        header = request.headers.get('Authorization')
        # header 에 token_encoded 를 넣어서 request
        if header is None: 
            return {"message": "Please Login"}, 404
        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)  # {'id':실제 id} 딕셔너리형태로 돌려줌
        result = mongodb.delete_one(query={"id": token_decoded["id"]}, collection_name="user")

        if result.raw_result["n"] == 1:
            return{"query _status": "success"}
        else :
            return {"query_status": "해당 id의 사용자를 찾을 수 없습니다."}, 500
    


@Auth.route('/login')
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
        user_info = mongodb.find_one(query={"id": sign_info["id"]}, collection_name="user")  # 동일한 아이디불러오기
        
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
            token_encoded = jwt.encode({'id': user_info["id"]}, SECRET_KEY, ALGORITHM)
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
        user_info = mongodb.find_one(query={"id": token_decoded["id"]}, collection_name="user", projection_key={'_id': 0, "password": 0})
        
        return user_info,200
    

    def put(self):  # 회원정보수정
        """
        회원정보를 수정합니다
        """
        header = request.headers.get('Authorization')
        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM) #인코드된 토큰 받아서 디코드함

        user_info = request.get_json()
        result = mongodb.update_one(query={"id": token_decoded["id"]}, collection_name="user", modify={"$set": user_info["modify"]})

        if result.raw_result["n"] == 1:
            modified_user = mongodb.find_one(query={"id": token_decoded["id"]},
                                             collection_name="user",
                                             projection_key={"_id": 0, "password":0})

            return modified_user
        else:

            return {"query_status": "해당 id의 사용자를 찾을 수 없습니다"}, 500

