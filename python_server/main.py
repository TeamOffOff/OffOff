from flask import Flask, request, jsonify  # 서버 구현을 위한 Flask 객체 import
from flask_restx import Api, Resource

import mongo

app = Flask(__name__)
api = Api(app)


@api.route("/SignUp")
class SignUp(Resource):
    def post(self):
        user_info = request.get_json()

        if not mongodb.find_one({"id": user_info["id"]}):
            mongodb.insert_one(user_info)
            return {"query_status": "success"}
        else:
            return {"query_status": "fail"}


@api.route("/SignIn")
class SignIn(Resource):
    def post(self):
        sign_info = request.get_json()
        user_info = mongodb.find_one({"id": sign_info["id"]})

        if not user_info:
            return {"query_status": "유효하지않은 id입니다."}

        if user_info["password"] != sign_info["password"]:
            return {"query_status": "틀린 비밀번호입니다."}
        else:
            return {"query_status": "success"}


if __name__ == "__main__":
    mongodb = mongo.MongoHelper()
    app.run(debug=True, host="0.0.0.0", port=5000)
