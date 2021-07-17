import jwt
import bcrypt
from flask import request
from flask_restx import Resource, Api, Namespace, fields

import mongo

mongodb = mongo.MongoHelper()

users = {}
Auth = Namespace("Auth")

#입력, 출력에 대한 스키마를 나타내는 객체 ===> 몽고디비도 스키마가 필요할까? (user.py참고)


#Api 생성
@Auth.route('/register') #Blueprint Namespace차이 공부
class AuthRegister(Resource):
    #사용자가 회원가입하는 경우
    @Auth.doc(responses={200: 'Success'}) #dict 객체를 받으며, 키로는 Status Code, 값으로는 설멍을 적을 수 있습니다.
    @Auth.doc(responses={500: 'Register Failed'})
    def post(self):
        user_info = request.get_json() #위와 같은 데이터를 POST 방식으로 body 에 실어서 보내면 flask 에서는 request.get_json() 을 이용해서 파이썬 데이터 형식으로 변환해서 가져올 수 있습니다
        #사용자가 입력한 회원가입 정보를 json형태로 저장
        if mongodb.find_one(query={"id": user_info["id"]}, collection_name="user_collection"):
            return {
                "message": "The ID already exist"
            }, 500
            #이미 해당 아이디가 있는 경우
        else:
            #해당 아이디가 없으면 password를 암호화해서 저장
            encrypted_password = bcrypt.hashpw(str(user_info["password"]).encode("utf-8"), bcrypt.gensalt()) #비밀번호를 암호화 (이제 json에 아이디랑 암호화된 비밀번호가 매칭되어있음)
            user_info["password"] = encrypted_password
            # user_info["password"] = encrypted_password.decode("utf-8") 이거 두개 중에 뭘 해야하는거지?
            # """이렇게 encrypted_password는 bcrypt 암호화 방식으로 암호화된 bytes-string 객체가 되었습니다. 
            # 이를 또 UTF-8 방식으로 디코딩하여, str 객체로 데이터 베이스에 저장 하여 주면 됩니다!"""
            mongodb.insert_one(user_info, collection_name="user_collection") #데이터베이스에 저장
            token_encoded = jwt.encode({'id':user_info["id"]}, "secret", algorithm="HS256")
            return {
                'Authorization' : token_encoded, #.decode("UTF-8"), #str으로 변환하여 Return
                "message" : 'Register Success'
            }, 200 #이게 토큰인거죠?

@Auth.route('/login')
class AuthLogin(Resource):
    #사용자가 로그인하는 경우
    @Auth.doc(responses={200: 'Sucess'})
    @Auth.doc(responses={404: 'User Not Found'})
    @Auth.doc(responses={500: 'Auth Failed'})
    def post(self):
        sign_info = request.get_json() #사용자가 입력한 아이디, 비밀번호를 클라이언트가 json으로 보내주면 여기에 저장
        input_password = sign_info["password"]
        user_info = mongodb.find_one(query={"id":sign_info["id"]}, collection_name="user_collection") 
        #동일한 아이디불러오기
        
        if not user_info :
            return {
                "message" : "Users Not Found"
            }, 404
        elif not bcrypt.checkpw(input_password.encode("utf-8"), user_info["password"]): #비밀번호 일치 확인(사용자가 입력한 걸 암호화해서? 아니면 데이터베이스에 있는 걸 풀어서?)
            return {
                "message": "Wrong Password"
            }, 500
        else:
            token_encoded = jwt.encode({'id':user_info["id"]}, "secret", algorithm="HS256")
            return {
                'Authorization': token_encoded, #.decode("UTF-8") python3는 utf-8이 기본이라서 decode할 필요가 없어서 decode함수도 없음, #str로 반환하여 return
                "message" : 'Login Success'
            }, 200 #id로 토큰만들기

#사용자 로그인에 성공하면 정보 전체 불러줘야함


@Auth.route('/get')
class AuthGet(Resource):
    @Auth.doc(responses={200: 'Success'})
    @Auth.doc(responses={404: 'Login Failed'})
    def get(self):
        header = request.headers.get('Authorization') #header에 token_encoded를 넣어서 request
        if header == None:
            return {"message": "Please Login"}, 404
        id_token = jwt.decode(header, "secret", algorithms="HS256") #{'id':실제 id} 딕셔너리형태로 돌려줌
        user_info = mongodb.find_one(query={"id":id_token["id"]}, collection_name="user_collection", projection_key={'_id':0, "password":0}) #찾는 것 까지 가능함

        return user_info,200

#헤더로 디코드한거 보내서 회원탈퇴까지 진행할 수 있는건가?
#비밀번호 변경하는 경우에는 해당 패스워드를 지우고 새로 입력받아야하는건가?
#회원정보 수정도 고려해봐야함
#로그아웃