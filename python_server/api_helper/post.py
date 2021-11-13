from datetime import datetime
from flask import request, make_response
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from pymongo.message import query
from flask_jwt_extended import jwt_required, get_jwt_identity

from controller.image import *
from controller.reference import *
from controller.filter import check_jwt, ownership_required
from controller.etc import get_variables, get_reply_list

import mongo as mongo

mongodb = mongo.MongoHelper()

Post = Namespace("post", description="게시물 관련 API")
TestPost = Namespace('testpost', description='post여러개')

@TestPost.route("")
class TestPostControl(Resource):
    def post(self):
        request_info = request.get_json()
        board_type =  request_info["boardType"]+"_board"
        posts = request_info["posts"]
        for post in posts:
            # user설정
            user = post["author"]
             # _id를 지움
            del post["_id"]

            # date 추가
            post["date"] = datetime.now()

            # 회원정보 embedded 형태로 return
            making_reference = MakeReference(board_type=board_type, user=user)
            author = making_reference.embed_author_information_in_object()
            post["author"] = author

            # views, likes, reports, bookmarks, replyCount 추가
            post["views"] = 0
            post["replyCount"] = 0
            post["likes"] = []
            post["reports"] = []
            post["bookmarks"] = []
        
            if post["image"]:
                post["image"] = save_image(post["image"], "post")
        
        insert_manay_post = mongodb.insert_many(collection_name=board_type, data=posts)
        print(insert_manay_post)
        return{"queryStatus": "good"}, 200

"""
게시글 관련 API
"""
@Post.route("")
class PostControl(Resource):
    @jwt_required()  # token이 있는지
    def get(self):
        """특정 id의 게시글을 조회합니다."""
        print(request)
        print(Resource)
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        print("user_id: ", user_id)
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board"

        # viewCount +1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                           collection_name=board_type,
                                           modify={"$inc": {"views": 1}})

        # 게시글 조회
        post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                collection_name=board_type)

        # 게시글이 없는 경우 post["image"] 조회시 NoneType 에러 발생
        if not post:
            response_result = make_response({"queryStatus": "not found"}, 404)
            print(response_result.status_code)
            return response_result

        post["image"] = get_image(post["image"], "post", "400")

        if update_status.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "views update fail"}, 500)
            return response_result

        post["_id"] = str(post["_id"])
        post["date"] = (post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
        response_result = make_response(post, 200)
        return response_result


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

        if result.raw_result["n"] == 0:  # 게시글 삭제 실패
            response_result = make_response({"queryStatus": "post delete fail"}, 500)

        elif activity_result.raw_result["n"] == 0:  # 활동 업데이트 실패
            reponse_result = make_response({"queryStatus": "delete activity fail"}, 500)

        else :
            response_result = make_response({"queryStatus": "success"}, 200)
        
        return response_result


    @jwt_required()  # token이 있는지
    def post(self):
        """게시글을 생성합니다."""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result
            
        # 클라이언트에서 받은 변수 가져오기
        request_info, post_id, board_type, user = get_variables()
        if not user:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

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
            response_result = make_response({"queryStatus": "update activity fail"}, 500)
        else:
            post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                    collection_name=board_type)
            post["_id"] = str(post["_id"])
            post["date"] = (post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
            response_result = make_response(post, 200)
        return response_result

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
                if activity == "likes":  # 좋아요는 취소가 불가능함
                    response_result = make_response({"queryStatus": "already like"}, 201)
                    return response_result
                else:  # 좋아요 이외의 활동은 취소가 가능함
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
                response_result = make_response({"queryStatus": "user activity update fail"}, 500)
                return response_result

        if result.raw_result["n"] == 0:  # 게시글 정보(string, likes, reports, bookmarks) 업데이트 실패한 경우
            response_result = make_response({"queryStatus": "post update fail"}, 500)
            return response_result
        else:
            modified_post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                             collection_name=board_type)

            modified_post["_id"] = str(modified_post["_id"])
            modified_post["date"] = (modified_post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
            response_result = make_response(modified_post, 200)
            return response_result



