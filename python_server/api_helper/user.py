from flask import request
from flask_restx import Resource, Api, Namespace, fields
import jwt
import bcrypt

import mongo

from .utils import SECRET_KEY, ALGORITHM

mongodb = mongo.MongoHelper()

Auth = Namespace(name="Auth", description="유저 관련 API")


@Auth.route('/register')
class AuthRegister(Resource):
    """
    중복확인, 회원가입
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


@Auth.route('/login')
class AuthLogin(Resource):
    """
    로그인, 회원정보
    """
    def post(self):
        """
        입력한 id, password 일치여부를 검사합니다
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


    def get(self):
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

