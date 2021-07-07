from flask import Flask, request  # 서버 구현을 위한 Flask 객체 import
from flask_restx import Api, Resource

import mongo

app = Flask(__name__)
api = Api(app)


@api.route("/SignUp")
class SignUp(Resource):
    def post(self):
        user_info = request.get_json()

        if not mongodb.find_one(query={"id": user_info["id"]}, collection_name="user_collection"):
            mongodb.insert_one(user_info)
            return {"query_status": "success"}
        else:
            return {"query_status": "fail"}


@api.route("/SignIn")
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


@api.route("/PutPost")
class PutPost(Resource):
    def post(self):
        post_info = request.get_json()

        if not mongodb.find_one(query={"content_id": post_info["content_id"]}, collection_name="post_collection"):
            mongodb.insert_one(data=post_info, collection_name="post_collection")
            return {"query_status": "success"}
        else:
            return {"query_status": "중복된 id입니다."}


@api.route("/GetPost/content_id=<string:post_id>")
class GetPost(Resource):
    def get(self, post_id):
        post_info = mongodb.find_one(query={"content_id": post_id}, collection_name="post_collection")
        del post_info["_id"]

        if not post_info:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}
        else:
            return post_info


@api.route("/DeletePost/content_id=<string:post_id>")
class DeletePost(Resource):
    def delete(self, post_id):
        mongodb.delete_one(query={"content_id": post_id}, collection_name="post_collection")

        return {"query_status": "success"}


if __name__ == "__main__":
    mongodb = mongo.MongoHelper()
    app.run(debug=True, host="0.0.0.0", port=5000)
