import jwt
import bcrypt
from flask import request
from flask_restx import Resource, Api, Namespace, fields

from .utils import SECRET_KEY, ALGORITHM
import mongo

mongodb = mongo.MongoHelper()

users = {}
Auth = Namespace("Auth")


# Api 생성
@Auth.route('/register')
class AuthRegister(Resource):
    # 사용자가 회원가입하는 경우
    @Auth.doc(responses={200: 'Success'})
    @Auth.doc(responses={500: 'Register Failed'})
    def get(self):
        # 중복 확인
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
        # 회원 등록
        user_info = request.get_json()

        encrypted_password = bcrypt.hashpw(str(user_info["password"]).encode("utf-8"), bcrypt.gensalt())  # 비밀번호를 암호화
        user_info["password"] = encrypted_password.decode("utf-8")  # 이를 또 UTF-8 방식으로 디코딩하여, str 객체로 데이터 베이스에 저장
        mongodb.insert_one(user_info, collection_name="user")  # 데이터베이스에 저장
        token_encoded = jwt.encode({'id': user_info["id"]}, SECRET_KEY, ALGORITHM)  # user 의 id로 토큰 생성(고유한 정보가 id 이므로)

        return {
            'Authorization': token_encoded,  # 디코딩 해서 return 해야하나?
            "message": 'Register Success'
        }, 200


@Auth.route('/login')
class AuthLogin(Resource):
    # 사용자가 로그인하는 경우
    @Auth.doc(responses={200: 'Sucess'})
    @Auth.doc(responses={404: 'User Not Found'})
    @Auth.doc(responses={500: 'Auth Failed'})
    def post(self):
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
                'Authorization': token_encoded,  # 디코딩 해서 return 해야하나?
                "message" : 'Login Success'
            }, 200


@Auth.route('/userinfo')
class AuthGet(Resource):
    @Auth.doc(responses={200: 'Success'})
    @Auth.doc(responses={404: 'Login Failed'})
    def get(self):
        header = request.headers.get('Authorization')
        # header 에 token_encoded 를 넣어서 request
        if header == None:  # header is None 으로 해도 가능한가?
            return {"message": "Please Login"}, 404
        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)  # {'id':실제 id} 딕셔너리형태로 돌려줌
        user_info = mongodb.find_one(query={"id": token_decoded["id"]}, collection_name="user", projection_key={'_id': 0, "password": 0})
        return user_info,200

# 헤더로 디코드한거 보내서 회원탈퇴까지 진행할 수 있는건가?
# 비밀번호 변경하는 경우에는 해당 패스워드를 지우고 새로 입력받아야하는건가?
# 회원정보 수정도 고려해봐야함
# 로그아웃
