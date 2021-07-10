from flask import request
from flask_restx import Resource, Namespace

import mongo

mongodb = mongo.MongoHelper()
Post = Namespace("post")


@Post.route("/content-id=<string:content_id>")
class PostControl(Resource):
    def get(self, content_id):
        post_info = mongodb.find_one(query={"content_id": content_id}, collection_name="post_collection")

        if not post_info:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}
        else:
            del post_info["_id"]
            return post_info

    def delete(self, content_id):
        result = mongodb.delete_one(query={"content_id": content_id}, collection_name="post_collection")

        if result.raw_result["n"] == 1:
            return {"query_status": "success"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}

    def put(self, content_id):
        post_info = request.get_json()

        if not mongodb.find_one(query={"content_id": content_id}, collection_name="post_collection"):
            mongodb.insert_one(data=post_info, collection_name="post_collection")
            return {"query_status": "success"}
        else:
            return {"query_status": "중복된 id입니다."}
