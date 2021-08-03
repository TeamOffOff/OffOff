from flask import request
from flask_restx import Resource, Namespace, fields
from bson.objectid import ObjectId

import mongo

mongodb = mongo.MongoHelper()

Post = Namespace("post", description="게시물 관련 API")
Comment = Namespace("comment", description="댓글 관련 API")
Subcomment = Namespace("subcomment", description="대댓글 관련 API")


# 게시글 관련 API
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

        result = mongodb.update_one(query={"_id": ObjectId(content_id)},
                                    collection_name=board_type,
                                    modify={"$set": post_info["modify"]})

        if result.raw_result["n"] == 1:
            modified_post = mongodb.find_one(query={"_id": ObjectId(content_id)},
                                             collection_name=board_type,
                                             projection_key={"_id": False})

            return modified_post
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500


# 댓글 관련 API
@Comment.route("")
class CommentControl(Resource):
    """ 댓글생성, 수정, 삭제, 조회(대댓글 포함) """

    def post(self):  # 댓글 작성
        """댓글을 생성합니다."""
        comment_info = request.get_json()
        """
        {
            "board_type": free,
            "content_id": string,
            "comment": {
                "author": string,
                "content": string,
                "date": string?,
                "likes": integer
            },
            "subcomment": [
                {
                    "author": string,
                    "content": string,
                    "date": string?,
                    "likes": integer
                },
                {
                     "author": string,
                     "content": string,
                     "date": string?,
                    "likes": integer
                }
            ]
        }
        """

        board_type = comment_info["board_type"] + "_board_comment"

        comment_id = mongodb.insert_one(data=comment_info, collection_name=board_type)

        return {"query_status": [str(comment_id), board_type]}

    def get(self):  # 댓글 조회
        """댓글을 조회합니다."""
        content_id = request.args.get("content-id")
        board_type = request.args.get("board-type") + "_board_comment"

        cursor = mongodb.find(query={"content_id": content_id},
                              collection_name=board_type,
                              projection_key={"comment": True, "subcomment": True})  # 댓글은 오름차순

        comment_list = []
        for doc in cursor:
            doc["_id"] = str(doc["_id"])
            comment_list.append(doc)

        return {
            "comment_list": comment_list
        }

    def delete(self):  # 댓글 삭제
        """댓글을 삭제합니다."""
        comment_info = request.get_json()
        board_type = comment_info["board_type"] + "_board_comment"
        comment_id = comment_info["comment_id"]  # 댓글 조회시 해당 댓글 고유의 _id를 포함해서 리턴함
        whether_subcomment = comment_info["subcomment"]

        if not whether_subcomment:  # 대댓글이 없는 경우
            result = mongodb.delete_one(query={"_id": ObjectId(comment_id)},
                                        collection_name=board_type)
        else:
            alert_delete = {
                "comment": {
                    "author": None,
                    "content": None,
                    "date": None,
                    "likes": None
                }
            }
            result = mongodb.update_one(query={"_id": ObjectId(comment_id)},
                                        collection_name=board_type,
                                        modify={"$set": alert_delete})

        if result.raw_result["n"] == 1:
            return {"query_status": "success"}
        else:
            return {"query_status": "해당 댓글을 찾을 수 없습니다."}, 500

    def put(self):  # 댓글 수정
        """댓글을 수정합니다."""
        comment_info = request.get_json()
        board_type = comment_info["board_type"] + "_board_comment"
        comment_id = comment_info["comment_id"]

        result = mongodb.update_one(query={"_id": ObjectId(comment_id)},
                                    collection_name=board_type,
                                    modify={"$set": comment_info["modify"]})

        if result.raw_result["n"] == 1:
            return {"query_status": "해당 댓글을 수정했습니다."}
        else:
            return {"query_status": "해당 댓글을 찾을 수 없습니다."}, 500


# 대댓글 관련 API
@Subcomment.route("")
class SubcommentControl(Resource):
    # 보통 댓글, 대댓글은 수정기능은 없는듯?
    # 함수명이랑 실제 method랑 불일치 문제
    # 대댓글 삭제하려면 삭제 버튼 눌렀을 때 해당 대댓글 전체를 알려줘야함(pull)
    def post(self):  # 대댓글 작성
        """
        대댓글 추가
        {
                "board_type": free,
                "content_id": string,  # 이건 필요없으려나
                "comment_id": string,
                "subcomment":
                    {
                        "author": string,
                        "content": string,
                        "date": string?,
                        "likes": integer
                    }
        }

        """
        subcomment_info = request.get_json()
        comment_id = subcomment_info["comment_id"]
        board_type = subcomment_info["board_type"] + "_board_comment"
        subcomment = subcomment_info["subcomment"]

        result = mongodb.update_one(query={"_id": ObjectId(comment_id)},
                                    collection_name=board_type,
                                    modify={"$push": {"subcomment": subcomment}})

        if result.raw_result["n"] == 1:
            return {"query_status": "대댓글을 등록했습니다."}
        else:
            return {"query_status": "대댓글 등록에 실패하였습니다."}, 500

    def delete(self):  # 대댓글 삭제
        """
        대댓글 삭제
        """
        subcomment_info = request.get_json()
        comment_id = subcomment_info["comment_id"]
        board_type = subcomment_info["board_type"] + "_board_comment"
        subcomment = subcomment_info["subcomment"]

        result = mongodb.update_one(query={"_id": ObjectId(comment_id)},
                                    collection_name=board_type,
                                    modify={"$pull": {"subcomment": subcomment}})

        if result.raw_result["n"] == 1:
            return {"query_status": "대댓글을 삭제하였습니다."}
        else:
            return {"query_status": "대댓글 삭제에 실패하였습니다."}, 500
