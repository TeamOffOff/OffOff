from api_helper.user import ActivityControl
from flask import request
from flask_restx import Resource, Namespace, fields
from bson.objectid import ObjectId
from bson import json_util
import json
from api_helper.user import ActivityUpdate

import mongo

import dateutil.parser

mongodb = mongo.MongoHelper()

Post = Namespace("post", description="게시물 관련 API")
Reply = Namespace("reply", description="댓글 관련 API")
SubReply = Namespace("subreply", description="대댓글 관련 API")


# JSON 형태로 response하기 위해 string 타입으로 변환하는 함수
def convert_to_string(post):
    post["_id"] = str(post["_id"])
    post["date"] = str(post["date"])


# 게시글 관련 API
@Post.route("")
class PostControl(Resource):
    def get(self):  # 게시글 조회 / viewcount+1
        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board"

        # 게시글 조회
        post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                  collection_name=board_type)
        

        # viewCount +1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                           collection_name=board_type,
                                           modify={"$inc": {"viewCount": 1}})

        
        if not post:
            return {"queryStatus": "not found"}, 500

        elif update_status.raw_result["n"] == 0:
            return {"queryStatus": "viewCount update fail"}, 500

        else:
            # # 작성자 정보 조회
            # author = mongodb.find_one(query={"nickname": post["author"]}, collection_name="user", projection_key={"subinfo": True})
            
            # if not author:  # 작성자가 탈퇴한 경우
            #     post["author"] = None
            # else:
            #     post["author"] = author
            convert_to_string(post=post)

            return post



    def delete(self):  # 게시글 삭제
        """특정 id의 게시글을 삭제합니다."""
        post_info = request.get_json()
        post_id = post_info["_id"]
        board_type = post_info["boardType"] + "_board"

        # 게시글 삭제
        result = mongodb.delete_one(query={"_id": ObjectId(post_id)}, collection_name=board_type)

        # 회원활동정보 삭제
        post_activity = [post_info["boardType"], str(post_id)]
        author = post_info["author"]

        update_activity = ActivityUpdate(author=author, field="activity.posts", new_activity_info=post_activity)
        update_activity.update_activity(operator="$pull")

        if result.raw_result["n"] == 1:
            return {"queryStatus": "success"}
        else:
            return {"queryStatus": "post delete fail"}, 500


    def post(self):  # 게시글 생성
        """게시글을 생성합니다."""
        try:
            post_info = request.get_json()
            board_type = post_info["boardType"] + "_board"
            post_input = post_info
            

            del post_info["_id"]
            post_info["date"] = dateutil.parser.parse(post_info["date"])
            
            # 게시글 등록
            post_id = mongodb.insert_one(data=post_info, collection_name=board_type)

            # 회원정보 embeded 형태로 return
            author = post_info["author"]["_id"]

            embeded_author_info = {
                "author": {}
            }
            author_info = mongodb.find_one(query={"_id":author}, collection_name="user")
            embeded_author_info["author"]["_id"] = author_info["_id"]
            embeded_author_info["author"]["nickname"] = author_info["subInformation"]["nickname"]
            embeded_author_info["author"]["type"] = author_info["information"]["type"]
            embeded_author_info["author"]["profileImage"] = author_info["subInformation"]["profileImage"]

            post_update_result = mongodb.update_one(query={"_id":post_id}, collection_name=board_type, modify={"$set":  embeded_author_info})

            post = mongodb.find_one(query={"_id":post_id}, collection_name=board_type)

            convert_to_string(post=post)

            # 회원활동정보 등록
            post_activity = [post["boardType"], str(post_id)]

            update_activity = ActivityUpdate(author=author, field="activity.posts", new_activity_info=post_activity)
            update_activity.update_activity(operator="$addToSet")

            # if post_update_result["n"] == 1:



            return post

        except TypeError as t:
            return {
                "TypeError" : str(t)
            }
        except AttributeError as a:
            return {
                "AttributeError": str(a)
            }
        except IndexError as i:
            return {
                "IndexError": str(i)
            } 
        except dateutil.parser.ParserError as  p:
            return {
                "DatetimeError": str(p)
            } 



    def put(self):  # 게시글 수정
        """특정 id의 게시글을 수정합니다."""
        post_info = request.get_json()
        post_id = post_info["_id"]
        board_type = post_info["boardType"] + "_board"
        
        # 직전 좋아요 수 저장
        past_likes = mongodb.find_one(query={"_id": ObjectId(post_id)}, collection_name=board_type, projection_key={"_id":False, "likes":True})

        past_likes = past_likes["likes"]

        # 프론트에서 받은 JSON의 _id 삭제
        del post_info["_id"]

        # string 관련 정보
        article_key = ["title", "content", "image"]

        # integer 관련 정보 : bookmarkCount는 post에 필요 없음
        activity_key = ["likes", "viewCount", "reportCount", "replyCount"]

        modified_article = {}
        modified_activity = {}

        for key in post_info.keys():
            if key in article_key:
                modified_article[key] = post_info[key]
            elif key in activity_key:
                modified_activity[key] = post_info[key]

        # string 수정
        if None in list(modified_activity.values()):
            result = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                        collection_name=board_type,
                                        modify={"$set": modified_article})

        # integer 수정
        else:
            result = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                        collection_name=board_type,
                                        modify={"$inc": modified_activity})
        


        if result.raw_result["n"] == 1:
            modified_post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                             collection_name=board_type)

            # 인기게시판 관련
            if (past_likes < 10) and (modified_post["likes"] == 10) :
                hot_post_info={}
                
                # hot_board 컬렉션에 저장할 key 값
                hot_board_element = ["_id", "boardType", "date"]
    
                for key in hot_board_element:
                    hot_post_info[key] = modified_post[key]
                
                mongodb.insert_one(data=hot_post_info, collection_name="hot_board")
            
            elif (past_likes >= 10) and (modified_post["likes"] < 10):
                mongodb.delete_one(query={"_id": ObjectId(post_id)}, collection_name="hot_board")
            
            convert_to_string(post=modified_post)
            
            return modified_post

        else:
            return {"queryStatus": "post modify fail"}, 500


# 댓글 조회 함수
def get_reply_list(post_id, board_type):
    cursor = mongodb.find(query={"postId": post_id},
                              collection_name=board_type)  # 댓글은 오름차순

    reply_list = []
    for reply in cursor:
        reply["_id"] = str(reply["_id"])
        reply_list.append(reply)
    
    return reply_list


# 댓글 관련 API
@Reply.route("")
class CommentControl(Resource):
    """ 댓글생성, 삭제, 조회(대댓글 포함) """

    def post(self):  # 댓글 작성
        """댓글을 생성합니다."""
        reply_info = request.get_json()
        del reply_info["_id"]

        board_type = reply_info["boardType"] + "_board_reply"

        post_id = reply_info["postId"]

        mongodb.insert_one(data=reply_info, collection_name=board_type)

        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        
        return {
            "replyList": reply_list
        }


    def get(self):  # 댓글 조회
        """댓글을 조회합니다."""

        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board_reply"
        
        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        return {
            "replyList": reply_list
        }


    def delete(self):  # 댓글 삭제
        """댓글을 삭제합니다."""
        reply_info = request.get_json()
        post_id = reply_info["postId"]
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
        
        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        if result.raw_result["n"] == 1:
            return {
            "replyList": reply_list
        }
        else:
            return {"queryStatus": "reply delete failed"}, 500


# 대댓글 변수 설정 함수
def get_subreply_variable():
    subreply_info = request.get_json()
    post_id = subreply_info["postId"]
    reply_id = subreply_info["replyId"]
    board_type = subreply_info["boardType"] + "_board_reply"
    subreply = subreply_info["subReply"]

    return post_id, reply_id, board_type, subreply


# 대댓글 관련 API
@SubReply.route("")
class SubcommentControl(Resource):
    # 함수명이랑 실제 method랑 불일치 문제
    # 대댓글 삭제하려면 삭제 버튼 눌렀을 때 해당 대댓글 전체를 알려줘야함(pull)
    def post(self):  # 대댓글 작성
        """
        대댓글 추가
        """
        post_id, reply_id, board_type, subreply = get_subreply_variable()

        result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                    collection_name=board_type,
                                    modify={"$push": {"subReply": subreply}})

        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        if result.raw_result["n"] == 1:
            return {
            "replyList": reply_list
        }
        else:
            return {"queryStatus": "subreply register fail"}, 500


    def delete(self):  # 대댓글 삭제
        """
        대댓글 삭제
        """
        post_id, reply_id, board_type, subreply = get_subreply_variable()

        result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                    collection_name=board_type,
                                    modify={"$pull": {"subReply": subreply}})

        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        if result.raw_result["n"] == 1:
            return {
            "replyList": reply_list
        }
        else:
            return {"queryStatus": "subreply delete failed"}, 500