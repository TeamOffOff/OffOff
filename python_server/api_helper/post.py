from flask import request
from flask_restx import Resource, Namespace, fields
from bson.objectid import ObjectId

import mongo

mongodb = mongo.MongoHelper()
Post = Namespace("post", description="게시물 관련 API")


@Post.route("")
class PostControl(Resource):
    """
    input shape
    {
        content_id:~~,
        board_type:~~
    }
    """
    def get(self):
        content_id = request.args.get("content-id")
        board_type = request.args.get("board-type") + "_board"

        result = mongodb.find_one(query={"_id": ObjectId(content_id)},
                                  collection_name=board_type,
                                  projection_key={"_id": False})

        if not result:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500
        else:
            return result

    def delete(self):  # 게시글 삭제
        """특정 id의 게시글을 삭제합니다."""
        post_info = request.get_json()
        content_id = post_info["content_id"]
        board_type = post_info["board_type"] + "_board"

        result = mongodb.delete_one(query={"_id": ObjectId(content_id)}, collection_name=board_type)

        if result.raw_result["n"] == 1:
            return {"query_status": "success"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500

    def post(self):  # 게시글 생성
        """게시글을 생성합니다."""
        post_info = request.get_json()
        board_type = post_info["board_type"] + "_board"

        post_id = mongodb.insert_one(data=post_info, collection_name=board_type)

        return {"query_status": str(post_id)}

    def put(self):  # 게시글 수정
        """특정 id의 게시글을 수정합니다."""
        post_info = request.get_json()
        content_id = post_info["content_id"]
        board_type = post_info["board_type"] + "_board"

        result = mongodb.update_one(query={"_id": ObjectId(content_id)}, collection_name=board_type, modify={"$set": post_info["modify"]})

        if result.raw_result["n"] == 1:
            modified_post = mongodb.find_one(query={"_id": ObjectId(content_id)},
                                             collection_name=board_type,
                                             projection_key={"_id": False})

            return modified_post
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500