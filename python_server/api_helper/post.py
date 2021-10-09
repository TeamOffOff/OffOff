from datetime import datetime
from flask import request
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from flask_jwt_extended import jwt_required, get_jwt_identity

from controller.image import *
from controller.reference import *
from controller.filter import check_jwt, ownership_required
from controller.etc import get_variables, get_reply_list
import mongo as mongo

mongodb = mongo.MongoHelper()

Search = Namespace("search", description="검색 관련 API")
Post = Namespace("post", description="게시물 관련 API")
Reply = Namespace("reply", description="댓글 관련 API")

"""
검색 관련 API
"""
@Search.route("")
class SearchControl(Resource):
    def get(self):
        # 회원여부 가려야함

        keyward = request.args.get("key")

        # 전체 게시판에서 모두 찾아야함


        # content만 할 것인지? 아니면 title도 할 것인지
        result = list(mongodb.find(collection_name="free_board",query={"content":{"$regex":keyward}}))
        
        # 최신순(내림차순)으로 정렬해야함 : mongodb에서 가져온 직후에는 오름차순임
        for post in result:
            post["_id"] = str(post["_id"])
            post["date"] = str(post["date"])
        
        return{
            "postList": result
        }



"""
게시글 관련 API
"""

@Post.route("")
class PostControl(Resource):
    @jwt_required()  # token이 있는지
    def get(self):
        """특정 id의 게시글을 조회합니다."""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        print("user_id: ", user_id)
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board"

        # viewCount +1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                           collection_name=board_type,
                                           modify={"$inc": {"views": 1}})

        # 게시글 조회
        post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                collection_name=board_type)

        post["image"] = get_image(post["image"], "post")

        if not post:
            return {"queryStatus": "not found"}, 404

        elif update_status.raw_result["n"] == 0:
            return {"queryStatus": "views update fail"}, 500

        else:
            post["_id"] = str(post["_id"])
            post["date"] = (post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
            return post, 200

    @ownership_required
    def delete(self):
        """특정 id의 게시글을 삭제합니다."""

        # 클라이언트에서 받은 변수 가져오기
        request_info, post_id, board_type, user = get_variables()

        # db 컬랙션 명으로 변경
        board_type = board_type + "_board"

        # 게시글 삭제
        result = mongodb.delete_one(query={"_id": ObjectId(post_id)}, collection_name=board_type)

        # 회원활동정보 삭제
        making_reference = MakeReference(board_type=board_type, user=user)
        activity_result = making_reference.link_activity_information_in_user(field="activity.posts", post_id=post_id, operator="$pull")

        if result.raw_result["n"] == 0:
            return {"queryStatus": "post delete fail"}, 500
        elif activity_result.raw_result["n"] == 0:
            return {"queryStatus": "delete activity fail"}, 500
        
        return {"queryStatus": "success"}, 200


    @jwt_required()  # token이 있는지
    def post(self):
        """게시글을 생성합니다."""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403
            
        # 클라이언트에서 받은 변수 가져오기
        request_info, post_id, board_type, user = get_variables()
        if not user:
            return {"queryStatus": "wrong Token"}, 403

        # db 컬랙션 명으로 변경
        board_type = board_type + "_board"

        # _id를 지움
        del request_info["_id"]

        # date 추가
        request_info["date"] = datetime.now()

        # 회원정보 embedded 형태로 return
        making_reference = MakeReference(board_type=board_type, user=user)
        author = making_reference.embed_author_information_in_object()
        request_info["author"] = author

        # views, likes, reports, bookmarks, replyCount 추가
        request_info["views"] = 0
        request_info["replyCount"] = 0
        request_info["likes"] = []
        request_info["reports"] = []
        request_info["bookmarks"] = []
        
        if request_info["image"]:
            request_info["image"] = save_image(request_info["image"], "post")
        
        print(request_info)

        # 게시글 저장
        post_id = mongodb.insert_one(data=request_info, collection_name=board_type)

        # 회원활동 정보 등록
        result = making_reference.link_activity_information_in_user(field="activity.posts", post_id=post_id, operator="$addToSet")

        # 등록완료된 게시글 조회
        if result.raw_result["n"] == 0:
            return {"queryStatus": "update activity fail"}, 500
        else:
            post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                    collection_name=board_type)
            post["_id"] = str(post["_id"])
            post["date"] = (post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")

            return post, 200

    @ownership_required
    def put(self):  # 게시글 수정
        """특정 id의 게시글을 수정합니다."""
        # 클라이언트에서 받은 변수 가져오기
        request_info, post_id, board_type, user = get_variables()

        # db 컬랙션 명으로 변경
        board_type = board_type + "_board"

        if "author" in request_info:  # string을 수정하는 경우
            print("String 수정하는 경우")
            article_key = ["title", "content", "image"]

            # _id 는 수정할 수 없는 정보이므로 삭제
            del request_info["_id"]

            # author는 데코레이터에서 역할이 끝났으므로 삭제
            del request_info["author"]

            # 게시글 정보 업데이트
            result = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                        collection_name=board_type,
                                        modify={"$set": request_info})

        else:  # integer을 수정하는 경우
            print("integer 수정하는 경우")

            activity = request_info["activity"]

            if activity == "likes":
                past_user_list = mongodb.find_one(query={"_id": ObjectId(post_id)}, collection_name=board_type, projection_key={"_id": False, activity: True})[activity]
                print(past_user_list)
                past_likes = len(past_user_list)
                print(past_likes)

            if user in past_user_list:  # 해당 활동을 한 적이 있는 경우
                if activity == "likes":
                    return {"queryStatus": "already like"}, 201
                else:
                    operator = "$pull"
                    result = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=board_type, modify={operator: {activity: user}})

            else:  # 해당활동을 한 적이 없는 경우
                operator = "$addToSet"
                result = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=board_type, modify={operator: {activity: user}})

                # 인기게시판 관련   
                if activity == "likes":

                    modified_post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                                     collection_name=board_type)
                    present_likes = len(modified_post["likes"])
                    print(present_likes)
                    if (past_likes < 10) and (present_likes == 10):
                        print("여기 좋아요 10 넘음")
                        hot_post_info = {}

                        # hot_board 컬렉션에 저장할 key 값
                        hot_board_element = ["_id", "boardType", "date"]

                        for key in hot_board_element:
                            hot_post_info[key] = modified_post[key]
                        print(hot_post_info)

                        mongodb.insert_one(data=hot_post_info, collection_name="hot_board")

            # 활동 업데이트
            making_reference = MakeReference(board_type=board_type, user=user)
            field = "activity." + activity

            activity_result = making_reference.link_activity_information_in_user(field=field, post_id=post_id, operator=operator)
            if activity_result.raw_result["n"] == 0:
                return {"queryStatus": "user activity update fail"}, 500

        if result.raw_result["n"] == 0:  # 게시글 정보(string, likes, reports, bookmarks) 업데이트 실패한 경우
            return {"queryStatus": "post update fail"}, 500
        else:
            modified_post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                             collection_name=board_type)

            modified_post["_id"] = str(modified_post["_id"])
            modified_post["date"] = (modified_post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")

            return modified_post



"""
댓글 관련 API
"""

# 댓글 관련 API
@Reply.route("")
class CommentControl(Resource):
    """ 댓글생성, 삭제, 조회(대댓글 포함) """
    @jwt_required()
    def post(self):  # 댓글 작성
        """댓글을 생성합니다."""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        # 클라이언트에서 받은 변수 가져오기
        request_info, post_id, board_type, user = get_variables()
        if not user:
            return {"queryStatus": "wrong Token"}, 403
        print(board_type)
        
        # post 컬랙션 이름으로
        post_board_type = board_type + "_board"
        print(post_board_type)

        # 댓글 수 +1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=post_board_type, modify={"$inc": {"replyCount": 1}})
        print(update_status)
        if update_status.raw_result["n"] == 0:
            return{"queryStatus": "replyCount update fail"}, 500

        # reply 컬랙션 이름으로
        reply_board_type = board_type + "_board_reply"
        print(reply_board_type)

        # date 추가
        request_info["date"] = datetime.now()

        # 회원정보 embedded 형태로 등록
        making_reference = MakeReference(board_type=reply_board_type, user=user)
        author = making_reference.embed_author_information_in_object()
        request_info["author"] = author

        # likes 추가
        request_info["likes"] = []

        # 댓글 db에 저장
        reply_id = mongodb.insert_one(data=request_info, collection_name=reply_board_type)

        # 회원활동 정보 link 형태로 등록
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=reply_id, operator="$addToSet")

        
        # 댓글 조회
        reply_list = get_reply_list(post_id=post_id, board_type=reply_board_type)

        return {
            "replyList": reply_list
        }

    @jwt_required()
    def get(self):  # 댓글 조회
        """댓글을 조회합니다."""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board_reply"

        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        return {
            "replyList": reply_list
        }

    @jwt_required()
    def put(self):  # 좋아요
        """좋아요를 저장합니다"""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403
        # 클라이언트에서 받은 변수 가져오기
        request_info, reply_id, board_type, user = get_variables()
        if not user:
            return {"queryStatus": "wrong Token"}, 403

        # db 컬랙션 명으로 변경
        board_type = board_type + "_board_reply"

        past_likes_list = mongodb.find_one(query={"_id": ObjectId(reply_id)}, collection_name=board_type, projection_key={"_id": False, "likes": True})["likes"]

        if user in past_likes_list:
            return {"queryStatus": "already like"}
        else:
            update_status = mongodb.update_one(query={"_id": ObjectId(reply_id)}, collection_name=board_type, modify={"$addToSet": {"likes": user}})

        if update_status.raw_result["n"] == 0:
            return {"queryStatus": "likes update fail"}, 500
        else:
            return {"queryStatus": "likes update success"}, 200


    @ownership_required
    def delete(self):  # 댓글 삭제
        """댓글을 삭제합니다."""
        # 클라이언트에서 받은 변수 가져오기
        request_info, reply_id, board_type, user = get_variables()
        post_id = request_info["postId"]
        print(board_type)

        # post 컬랙션 이름으로
        post_board_type = board_type + "_board"
        print(post_board_type)

        # 댓글 -1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=post_board_type, modify={"$inc": {"replyCount": -1}})

        if update_status.raw_result["n"] == 0:
            return{"queryStatus": "replyCount update fail"}, 500

        # reply 컬랙션 이름으로
        reply_board_type = board_type + "_board_reply"
        print(reply_board_type)

        whether_subreply = mongodb.find_one(query={"parentReplyId": reply_id}, collection_name=reply_board_type)
        print(whether_subreply)

        if not whether_subreply:  # 대댓글이 없는 경우
            result = mongodb.delete_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=reply_board_type)
        else:  # 대댓글이 있는 경우
            alert_delete = {
                "author": {"_id": None, "nickname": None, "type": None, "profileImage": None},
                "content": None,
                "date": None,
                "likes": None
            }
            result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=reply_board_type,
                                        modify={"$set": alert_delete})

        
        
        # 댓글 조회
        reply_list = get_reply_list(post_id=post_id, board_type=reply_board_type)

        # 회원활동정보 삭제
        making_reference = MakeReference(board_type=reply_board_type, user=user)
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=reply_id, operator="$pull")

        if result.raw_result["n"] == 0:
            return {"queryStatus": "reply delete failed"}, 500
        
        return {
                       "replyList": reply_list
                   }, 200