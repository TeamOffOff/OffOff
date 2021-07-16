from flask import request
from flask_restx import Resource, Namespace

import mongo

mongodb = mongo.MongoHelper()
Post = Namespace("post")


@Post.route("/")
class PostControl(Resource):
    """
    input shape
    {
        content_id:~~,
        board_type:~~
    }
    """
    def get(self):  # 게시글 조회
        post_info = request.get_json()
        content_id = post_info["content_id"]
        board_type = post_info["board_type"] + "_post"

        result = mongodb.find_one(query={"content_id": content_id}, collection_name=board_type)

        if not result:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}
        else:
            del post_info["_id"]
            return post_info

    def delete(self):  # 게시글 삭제
        post_info = request.get_json()
        content_id = post_info["content_id"]
        board_type = post_info["board_type"] + "_post"

        result = mongodb.delete_one(query={"content_id": content_id}, collection_name=board_type)

        if result.raw_result["n"] == 1:
            return {"query_status": "success"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}

    def post(self):  # 게시글 생성
        post_info = request.get_json()
        board_type = post_info["board_type"] + "_post"

        post_id = mongodb.insert_one(data=post_info, collection_name=board_type)

        return {"query_status": post_id}
