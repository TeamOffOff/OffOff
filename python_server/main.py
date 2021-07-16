from flask import Flask, request  # 서버 구현을 위한 Flask 객체 import
from flask_restx import Api, Resource
from api_helper.post import Post
from api_helper.board2 import BoardList, PostList

import mongo

app = Flask(__name__)
api = Api(app)

api.add_namespace(Post, "/post")
api.add_namespace(BoardList, "/boardlist")
api.add_namespace(PostList, "/postlist")


@api.route("/signup")
class SignUp(Resource):
    def post(self):
        user_info = request.get_json()

        if not mongodb.find_one(query={"id": user_info["id"]}, collection_name="user_collection"):
            mongodb.insert_one(user_info, collection_name="user_collection")
            return {"query_status": "success"}
        else:
            return {"query_status": "fail"}


@api.route("/signin")
class SignIn(Resource):
    def post(self):
        sign_info = request.get_json()
        user_info = mongodb.find_one(query={"id": sign_info["id"]}, collection_name="user_collection")

        if not user_info:
            return {"query_status": "유효하지않은 ID 입니다."}

        if user_info["password"] != sign_info["password"]:
            return {"query_status": "틀린 비밀번호입니다."}
        else:
            return {"query_status": "success"}


if __name__ == "__main__":
    mongodb = mongo.MongoHelper()
    app.run(debug=True, host="0.0.0.0", port=5000)
