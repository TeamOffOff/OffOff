from datetime import datetime
from flask import request
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from flask_jwt_extended import jwt_required, get_jwt_identity

from .image_control import *
from .user import check_jwt

import mongo

mongodb = mongo.MongoHelper()

Post = Namespace("post", description="게시물 관련 API")
Reply = Namespace("reply", description="댓글 관련 API")

""" 리펙토링 """

"""변수 추출하는 함수"""


@jwt_required()
def get_variables():
    user_id = check_jwt()
    # user_id가 있는지, blocklist는 아닌지
    # onwership_requried 데코레이터가 없는 곳에는
    # if not user_id:
    # return{"queryStatus": "wrong Token"}, 403 있어야함

    request_info = request.get_json()

    if "_id" in request_info:  # 게시글 작성, 게시글 수정/좋아요, 게시글 삭제 댓글/대댓글 좋아요, 댓글/대댓글의 삭제인 경우
        pk = request_info["_id"]
    else:  # 댓글 작성인 경우
        pk = request_info["postId"]

    board_type = request_info["boardType"]

    return request_info, pk, board_type, user_id


"""JSON 형태로 response하기 위해 string 타입으로 변환하는 함수"""


def convert_to_string(post, *args):
    for key in args:
        post[key] = str(post[key])


"""author 정보 embed, 활동 정보 link 클래스"""


class MakeReference:
    def __init__(self, board_type, user):
        self.board_type = board_type
        self.user = user

    # author 정보 embed
    def embed_author_information_in_object(self):

        embedded_author_info = {}

        total_author_info = mongodb.find_one(query={"_id": self.user}, collection_name="user")

        needed_author_info = ["_id", "subInformation.nickname", "information.type", "subInformation.profileImage"]

        for info in needed_author_info:
            if "." in info:
                field, key = info.split(".")
                embedded_author_info[key] = total_author_info[field][key]
            else:
                embedded_author_info[info] = total_author_info[info]

        return embedded_author_info

    # 활동 정보 link
    def link_activity_information_in_user(self, operator, field, post_id, reply_id=None):
        if reply_id:
            board_type = self.board_type.replace("_board_reply", "")
        else:
            board_type = self.board_type.replace("_board", "")

        # 회원탈퇴 시 댓글, 대댓글의 author을 None으로 바꾸려면 reply_id 필요함
        new_activity_info = [board_type, str(post_id), str(reply_id)]

        result = mongodb.update_one(query={"_id": self.user}, collection_name="user", modify={operator: {field: new_activity_info}})

        return result


"""수정, 삭제 시 작성자 확인"""


def ownership_required(func):
    @jwt_required()
    def wrapper(self):
        request_info = request.get_json()

        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        if "author" in request_info:  # 삭제, 수정은 author 넘겨받음
            author = (request.get_json())["author"]

            if author == user_id:
                result = func(self)
                return result
            else:
                return {"queryStatus": "작성자가 아닙니다"}, 403

        else:  # 게시글, 댓글 좋아요
            result = func(self)
            return result

    return wrapper


"""API 기능 구현"""

"""게시글 관련 API"""


@Post.route("")
class PostControl(Resource):
    def get(self):
        """특정 id의 게시글을 조회합니다."""
        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board"

        # viewCount +1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                           collection_name=board_type,
                                           modify={"$inc": {"views": 1}})

        # 게시글 조회
        post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                collection_name=board_type)

        post["Image"]["body"] = get_image(post["Image"]["key"])

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
        else:
            return {"queryStatus": "success"}, 200

    def post(self):
        """게시글을 생성합니다."""

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

        # views, likes, reports, bookmarks 추가
        request_info["views"] = 0
        request_info["likes"] = []
        request_info["reports"] = []
        request_info["bookmarks"] = []

        save_image(request_info["img"], "post")
        del request_info["img"]["body"]

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
                    return {"queryStatus": "already like"}
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


# 댓글 조회 함수
def get_reply_list(post_id=None, board_type=None):
    total_list = list(mongodb.find(query={"postId": post_id},
                                   collection_name=board_type))  # 댓글은 오름차순

    for reply in total_list:
        reply["_id"] = str(reply["_id"])
        if reply["date"]:
            reply["date"] = (reply["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")

    return total_list


# 댓글 관련 API
@Reply.route("")
class CommentControl(Resource):
    """ 댓글생성, 삭제, 조회(대댓글 포함) """

    def post(self):  # 댓글 작성
        """댓글을 생성합니다."""

        # 클라이언트에서 받은 변수 가져오기
        request_info, post_id, board_type, user = get_variables()
        if not user:
            return {"queryStatus": "wrong Token"}, 403

        # db 컬랙션 명으로 변경
        board_type = board_type + "_board_reply"

        # date 추가
        request_info["date"] = datetime.now()

        # 회원정보 embedded 형태로 등록
        making_reference = MakeReference(board_type=board_type, user=user)
        author = making_reference.embed_author_information_in_object()
        request_info["author"] = author

        # likes 추가
        request_info["likes"] = []

        # 댓글 db에 저장
        reply_id = mongodb.insert_one(data=request_info, collection_name=board_type)

        # 회원활동 정보 link 형태로 등록
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=reply_id, operator="$addToSet")

        # 댓글 조회
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

    def put(self):  # 좋아요
        """좋아요를 저장합니다"""
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

        # db 컬랙션 명으로 변경
        board_type = board_type + "_board_reply"

        whether_subreply = mongodb.find_one(query={"parentReplyId": reply_id}, collection_name=board_type)

        if not whether_subreply:  # 대댓글이 없는 경우
            result = mongodb.delete_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=board_type)
        else:  # 대댓글이 있는 경우
            alert_delete = {
                "author": {"_id": None, "nickname": None, "type": None, "profileImage": None},
                "content": None,
                "date": None,
                "likes": None
            }
            result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=board_type,
                                        modify={"$set": alert_delete})

        # 댓글 조회
        post_id = request_info["postId"]
        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        # 회원활동정보 삭제
        making_reference = MakeReference(board_type=board_type, user=user)
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=reply_id, operator="$pull")

        if result.raw_result["n"] == 1:
            return {
                       "replyList": reply_list
                   }, 200
        else:
            return {"queryStatus": "reply delete failed"}, 500
