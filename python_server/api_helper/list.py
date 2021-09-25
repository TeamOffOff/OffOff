from flask import request
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from datetime import datetime, timedelta
from flask_jwt_extended import jwt_required
from controller.filter import check_jwt
from pymongo import collection, message

import mongo as mongo

import pprint

mongodb = mongo.MongoHelper()

BoardList = Namespace(
    name="boardlist",
    description="게시판목록을 불러오는 API")

PostList = Namespace(
    name="postlist",
    description="게시글목록을 불러오는 API")

UserControl = Namespace(
    name="usercontrol",
    description="유저관련 기능"
)

MessageList = Namespace(
    "messagelist",
    description="메시지 목록을 불러오는 API"
)


@BoardList.route("")
# 사용자가 커뮤니티 탭을 클릭하는 경우
class BoardListControl(Resource):

    def get(self):  # 게시판 목록 불러오기

        total_list = list(mongodb.find(collection_name="board_list", projection_key={"_id": 0}))

        # 요청 시점
        access_on = datetime.now()

        # 기준 시점 = 요청 시점 - 3시간
        standard = access_on - timedelta(hours=3)

        # 해당 board의 컬렉션에 date가 3시간 이전인 게시글이 있는지
        for board in total_list:

            board_type = board["boardType"] + "_board"

            result = mongodb.find_one(collection_name=board_type, query={"date": {"$gte": standard}})
            if result:
                board["newPost"] = True

        return {
            "boardList": total_list
        }

    def delete(self):  # 게시판 목록 삭제
        """특정 게시판 정보를 삭제합니다."""
        board_info = request.get_json()
        board_type = board_info["boardType"]

        result = mongodb.delete_one(query={"boardType": board_type}, collection_name="board_list")

        if result.raw_result["n"] == 1:
            return {"queryStatus": "해당 게시판을 삭제했습니다."}
        else:
            return {"queryStatus": "게시판 삭제를 실패했습니다."}, 500

    def post(self):  # 게시판 목록 등록
        """특정 게시판 정보를 등록합니다."""
        board_info = request.get_json()

        mongodb.insert_one(data=board_info, collection_name="board_list")

        return {"queryStatus": "게시판을 등록했습니다"}


@UserControl.route("")
class UserListControl(Resource):

    def get(self):
        """
        유저 리스트 불러오는 api
        """
        func = request.args.get("func")
        if func == "userlist":
            result = list(mongodb.find(collection_name="user"))

        elif func == "blocklist":
            result = list(mongodb.find(collection_name="block_list"))
            for i in result:
                i["createdAt"] = str(i["createdAt"])

        return result

    def post(self):
        """
        token block 설정 위한 block_list 컬렉션 설정
        """
        result = mongodb.create_index(standard="createdAt", collection_name="block_list", expire_time=10)
        return {
            "queryStatus": result
        }


@PostList.route("/<string:board_type>")
# 사용자가 특정 게시판을 클릭하는 경우
class PostListControl(Resource):

    def get(self, board_type):  # 게시글 목록 불러오기
        """
        DB > 해당 게시판의 컬랙션(free_board)에서 게시글을 조회합니다
        """

        board_type = board_type + "_board"
        volume = int(request.args.get("volume", default=20))
        standard_id = request.args.get("standardId", default="")

        if not standard_id:  # 게시판에 처음 들어간 경우, 새로 고침한 경우

            total_list = list(mongodb.find(collection_name=board_type).sort([("_id", -1)]).limit(volume))

        elif standard_id:  # 과거 게시글 불러올 때

            standard_id = ObjectId(standard_id)
            total_list = list(mongodb.find(query={'_id': {'$lt': standard_id}}, collection_name=board_type).sort(
                [("_id", -1)]).limit(volume))

        if total_list:  # 불러올 게시글이 남아있는 경우
            for post in total_list:
                post["_id"] = str(post["_id"])
                post["date"] = (post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")

            last_post_id = total_list[-1]["_id"]

            if board_type == "hot_board":  # 인기게시판인 경우
                print("여기는 인기게시판")
                print("인기게시판db에 있는 정보", total_list)

                hot_post_list = []
                for temp_post in total_list:
                    post_id = ObjectId(temp_post["_id"])
                    board_type = temp_post["boardType"] + "_board"

                    post = mongodb.find_one(query={"_id": post_id}, collection_name=board_type)
                    post["_id"] = str(post["_id"])
                    post["date"] = str(post["date"])

                    hot_post_list.append(post)

                print("인기게시판에 들어간 각 게시글의 정보:", hot_post_list)

                return {
                    "lastPostId": last_post_id,
                    "postList": hot_post_list
                }

            else:
                return {
                    "lastPostId": last_post_id,
                    "postList": total_list
                }
        else:
            return {
                "lastPostId": None,
                "postList": None
            }

    def delete(self, board_type):  # 컬렉션 자체를 삭제

        result = mongodb.drop(collection_name=board_type)

        return {"queryStatus": result}


@MessageList.route("/<string:message_type>")  # send, receive
class MassageListControl(Resource):
    @jwt_required()
    def get(self, message_type):  # 쪽지 목록 불러오기
        """
        쪽지 리스트를 조회합니다
        """
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403
        print(user_id)
        message_field = (mongodb.find_one(query={"_id": user_id}, collection_name="user"))["message"]

        # 아직 message_type이 user db에 message field에 없으면 KeyError 발생
        if not (message_type in message_field):
            return {"queryStatus": "no list"}

        message_id_list = (mongodb.find_one(query={"_id": user_id}, collection_name="user"))["message"][message_type]
        print(message_id_list)

            

        # 회원활동 게시글 조회와 구조 동일
        message_list = []
        for message_id in message_id_list:
            print(message_id)
            message_id = message_id[1]
            result = mongodb.find_one(query={"_id": ObjectId(message_id)}, collection_name="message")
            if result:
                result["_id"] = str(result["_id"])
                result["date"] = (result["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
                message_list.append(result)

            else:
                continue
            
            message_list.sort(key=lambda x: x["_id"], reverse=True)

            return{
                f"{message_type}List": message_list
            }, 200

