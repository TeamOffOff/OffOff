from flask import request
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from datetime import datetime, timedelta

from pymongo import collection


import mongo

mongodb = mongo.MongoHelper()


BoardList = Namespace(
    name="boardlist",
    description="게시판목록을 불러오는 API")

PostList = Namespace(
    name="postlist",
    description="게시글목록을 불러오는 API")

UserList = Namespace(
    name="userlist",
    description="유저목록을 불러오는 API"
)


@BoardList.route("")
# 사용자가 커뮤니티 탭을 클릭하는 경우
class BoardListControl(Resource):

    def get(self):  # 게시판 목록 불러오기

        cursor = mongodb.find(collection_name="board_list", projection_key={"_id": 0})
        
        access_on = datetime.now()
        standard = access_on - timedelta(hours=3)

        board_list = []
        for board in cursor:
            
            board_type = board["boardType"]+"_board"
            
            result = mongodb.find_one(collection_name=board_type, query={"date": {"$gte": standard}})
            
            if result:
                board["newPost"] = True

            # result = mongodb.aggregate(collection_name=board_type, pipeline=[{"$match": {"date": {"$gte":standard}}}])
            # temp_board_list = []
            # for new_post in result:
            #     temp_board_list.append(new_post)
            
            # if temp_board_list:
            #     board["newPost"] = True
            
            board_list.append(board)

        return {
            "boardList": board_list
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


@UserList.route("")
class UserListControl(Resource):
    def get(self):
        cursor = mongodb.find(collection_name="user")
        
        user_list = []
        for user in cursor:
            user_list.append(user)
        
        return user_list


@PostList.route("/<string:board_type>")
# 사용자가 특정 게시판을 클릭하는 경우
class PostListControl(Resource):

    def get(self, board_type):  # 게시글 목록 불러오기
        """
        DB > 해당 게시판의 컬랙션(free_board)에서 게시글을 조회합니다
        """
        try:

            board_type = board_type + "_board"
            volume = int(request.args.get("volume", default=20))
            standard_id = request.args.get("standardId", default="")

            if not standard_id:  # 게시판에 처음 들어간 경우, 새로 고침한 경우
                cursor = mongodb.find(collection_name=board_type).sort([("_id", -1)]).limit(volume)
            
            elif standard_id:  # 과거 게시글 불러올 때
                standard_id = ObjectId(standard_id)
                cursor = mongodb.find(query={'_id': {'$lt': standard_id}}, collection_name=board_type).sort(
                    [("_id", -1)]).limit(volume)

            post_list = []
            for post in cursor:
                post["_id"] = str(post["_id"])

                if board_type != "hot_board":
                    post["date"] = str(post["date"])
                
                post_list.append(post)

            last_post_id = post_list[-1]["_id"]

            if board_type == "hot_board":  # 인기게시판인 경우
                print("여기는 인기게시판")
                print(post_list)
                hot_post_list = []
                for temp_post in post_list:
                    post_id = temp_post["_id"]
                    board_type = temp_post["boardType"]+"_board"

                    post = mongodb.find_one(query={"_id": ObjectId(post_id)}, collection_name=board_type)
                    post["_id"] = str(post["_id"])
                    post["date"] = str(post["date"])

                    hot_post_list.append(post)

                return {
                    "lastPostId": last_post_id,
                    "postList": hot_post_list
                }
            
            else:
                return {
                    "lastPostId": last_post_id,
                    "postList": post_list
                }

        except IndexError:  # 일반 게시판 더 이상 없는 경우
            return {
                "lastPostId": None,
                "postList": None
            }
        except TypeError:  # 인기 게시판 더 이상 없는 경우
            return {
                "lastPostId": None,
                "postList": None
            }
    
    def delete(self, board_type):  # 컬렉션 자체를 삭제
        
        result = mongodb.drop(collection_name=board_type)
        
        return {"queryStatus": result}


