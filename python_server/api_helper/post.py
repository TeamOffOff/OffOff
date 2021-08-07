from flask import request
from flask_restx import Resource, Namespace, fields
from bson.objectid import ObjectId

import mongo

import dateutil.parser

mongodb = mongo.MongoHelper()

Post = Namespace("post", description="게시물 관련 API")
Reply = Namespace("reply", description="댓글 관련 API")
SubReply = Namespace("subreply", description="대댓글 관련 API")


# 게시글 관련 API
@Post.route("")
class PostControl(Resource):
    def get(self):  # 게시글 조회 / 댓글조회 / viewcount+1
        content_id = request.args.get("content-id")
        board_type = request.args.get("board-type") + "_board"
        reply_board_type = request.args.get("board-type")+"_board_reply"

        post = mongodb.find_one(query={"_id": ObjectId(content_id)},
                                  collection_name=board_type,
                                  projection_key={"_id": False})

        update_status = mongodb.update_one(query={"_id": ObjectId(content_id)},
                                           collection_name=board_type,
                                           modify={"$inc": {"viewCount": 1}})

        reply = mongodb.find_one(query={"postId": content_id},collection_name=reply_board_type)

        if not post:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500
        elif update_status.raw_result["n"] == 0:
            return {"query_status": "viewCount update fail"}, 500
        else:
            return {"post": post, "reply": reply}

    def delete(self):  # 게시글 삭제
        """특정 id의 게시글을 삭제합니다."""
        post_info = request.get_json()
        content_id = post_info["_id"]
        board_type = post_info["boardType"] + "_board"

        result = mongodb.delete_one(query={"_id": ObjectId(content_id)}, collection_name=board_type)

        if result.raw_result["n"] == 1:
            return {"query_status": "success"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500

    def post(self):  # 게시글 생성
        """게시글을 생성합니다."""
        post_info = request.get_json()
        board_type = post_info["boardType"] + "_board"

        del post_info["_id"]
        post_info["date"]=dateutil.parser.parse(post_info["date"])

        post_id = mongodb.insert_one(data=post_info, collection_name=board_type)

        return {"query_status": str(post_id)}

    def put(self):  # 게시글 수정
        """특정 id의 게시글을 수정합니다."""
        post_info = request.get_json()
        content_id = post_info["_id"]
        board_type = post_info["boardType"] + "_board"

        del post_info["_id"]

        article_key = ["title", "content", "image"]
        activity_key = ["likes", "viewCount", "reportCount", "replyCount"]

        modified_article = {}
        modified_activity = {}

        for key in post_info.keys():
            if key in article_key:
                modified_article[key] = post_info[key]
            elif key in activity_key:
                modified_activity[key] = post_info[key]

        if None in list(modified_activity.values()):
            result = mongodb.update_one(query={"_id": ObjectId(content_id)},
                                        collection_name=board_type,
                                        modify={"$set": modified_article})
        else:
            result = mongodb.update_one(query={"_id": ObjectId(content_id)},
                                        collection_name=board_type,
                                        modify={"$inc": modified_activity})
        


        if result.raw_result["n"] == 1:
            modified_post = mongodb.find_one(query={"_id": ObjectId(content_id)},
                                             collection_name=board_type)
            modified_post["_id"] = str(modified_post["_id"])

            if modified_post["likes"] >= 10 :
                hot_post_info={}
                hot_post_info["_id"] = modified_post["_id"]
                hot_post_info["boardType"] = modified_post["boardType"]

                mongodb.insert_one(data=hot_post_info, collection_name="hot_board")
            
            # 10 -> 9 가 된 경우 삭제하기


                
            return modified_post
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500


# 댓글 관련 API
@Reply.route("")
class CommentControl(Resource):
    """ 댓글생성, 삭제, 조회(대댓글 포함) """

    def post(self):  # 댓글 작성
        """댓글을 생성합니다."""
        """
        {
            "_id":
            "boardType":
            "postId":
            "reply": {
                "author":
                "content":
                "date":
                "likes":
            },
            "subReply":[]
        }
        """
        reply_info = request.get_json()
        del reply_info["_id"]

        board_type = reply_info["boardType"] + "_board_reply"

        reply_id = mongodb.insert_one(data=reply_info, collection_name=board_type)

        return {"query_status": str(reply_id)}

    def get(self):  # 댓글 조회
        """댓글을 조회합니다."""
        """
        {
            "_id":
            "boardType":
            "postId":
            "reply": {
                "author":
                "content":
                "date":
                "likes":
            },
            "subReply":[
                {
                    "author":
                    "content":
                    "date":
                    "likes":
                }
            ]
        }
        """
        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board_reply"

        cursor = mongodb.find(query={"_id": post_id},
                              collection_name=board_type,
                              projection_key={"reply": True, "subReply": True})  # 댓글은 오름차순

        reply_list = []
        for reply in cursor:
            reply["_id"] = str(reply["_id"])
            reply_list.append(reply)

        return {
            "reply_list": reply_list
        }

    def delete(self):  # 댓글 삭제
        """댓글을 삭제합니다."""
        reply_info = request.get_json()
        board_type = reply_info["boardType"] + "_board_reply"
        reply_id = reply_info["_id"]  # 댓글 조회시 해당 댓글 고유의 _id를 포함해서 리턴함
        whether_subreply = reply_info["subReply"]

        if not whether_subreply:  # 대댓글이 없는 경우
            result = mongodb.delete_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=board_type)
        else:
            alert_delete = {
                "reply": {
                    "author": None,
                    "content": None,
                    "date": None,
                    "likes": None
                }
            }
            result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=board_type,
                                        modify={"$set": alert_delete})

        if result.raw_result["n"] == 1:
            return {"query_status": "success"}
        else:
            return {"query_status": "해당 댓글을 찾을 수 없습니다."}, 500


# 대댓글 관련 API
@SubReply.route("")
class SubcommentControl(Resource):
    # 함수명이랑 실제 method랑 불일치 문제
    # 대댓글 삭제하려면 삭제 버튼 눌렀을 때 해당 대댓글 전체를 알려줘야함(pull)
    def post(self):  # 대댓글 작성
        """
        대댓글 추가
        {
                "boardType": free,
                "replyId": string,
                "subReply":
                    {
                        "author": string,
                        "content": string,
                        "date": string?,
                        "likes": integer
                    }
        }
        """
        subreply_info = request.get_json()
        reply_id = subreply_info["replyId"]
        board_type = subreply_info["boardType"] + "_board_reply"
        subreply = subreply_info["subReply"]

        result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                    collection_name=board_type,
                                    modify={"$push": {"subReply": subreply}})

        if result.raw_result["n"] == 1:
            return {"query_status": "대댓글을 등록했습니다."}
        else:
            return {"query_status": "대댓글 등록에 실패하였습니다."}, 500

    def delete(self):  # 대댓글 삭제
        """
        대댓글 삭제
        """
        subreply_info = request.get_json()
        reply_id = subreply_info["replyId"]
        board_type = subreply_info["boardType"] + "_board_reply"
        subreply = subreply_info["subReply"]

        result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                    collection_name=board_type,
                                    modify={"$pull": {"subReply": subreply}})

        if result.raw_result["n"] == 1:
            return {"query_status": "대댓글을 삭제하였습니다."}
        else:
            return {"query_status": "대댓글 삭제에 실패하였습니다."}, 500