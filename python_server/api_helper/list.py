from abc import abstractclassmethod
from flask import request
from flask.helpers import make_response
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from datetime import datetime, timedelta

from flask_jwt_extended import jwt_required
from controller.filter import check_jwt
from controller.image import *

import mongo as mongo

mongodb = mongo.MongoHelper()


BoardList = Namespace(
    name="boardlist",
    description="게시판목록을 불러오는 API")

@BoardList.route("")
# 사용자가 커뮤니티 탭을 클릭하는 경우
class BoardListControl(Resource):

    def get(self):  # 게시판 목록 불러오기

        total_list = list(mongodb.find(collection_name="board_list", projection_key={"_id": 0}))

        # 요청 시점
        access_on = datetime.now()

        # 기준 시점 = 요청 시점 - 3시간
        standard = access_on - timedelta(hours=3)

        # NewPost : 해당 board의 컬렉션에 date가 3시간 이전인 게시글이 있는지
        for board in total_list:

            board_type = board["boardType"] + "_board"

            result = mongodb.find_one(collection_name=board_type, query={"date": {"$gte": standard}})
            if result:
                board["newPost"] = True

        response_result = make_response({
            "boardList": total_list
        }, 200)

        return response_result 


    def delete(self):  # 게시판 목록 삭제
        """특정 게시판 정보를 삭제합니다."""
        board_info = request.get_json()
        board_type = board_info["boardType"]

        result = mongodb.delete_one(query={"boardType": board_type}, collection_name="board_list")

        if result.raw_result["n"] == 1:
            response_result = make_response({"queryStatus": "해당 게시판을 삭제했습니다."}, 200)
        else:
            response_result = make_response({"queryStatus": "게시판 삭제를 실패했습니다."}, 500)
        
        return response_result


    def post(self):  # 게시판 목록 등록
        """특정 게시판 정보를 등록합니다."""
        board_info = request.get_json()

        mongodb.insert_one(data=board_info, collection_name="board_list")

        response_result = make_response({"queryStatus": "게시판을 등록했습니다"}, 200)

        return response_result



PostList = Namespace(
    name="postlist",
    description="게시글목록을 불러오는 API")

@PostList.route("/<string:board_type>")
# 사용자가 특정 게시판을 클릭하는 경우
class PostListControl(Resource):

    def get(self, board_type):  # 게시글 목록 불러오기
        """
        DB > 해당 게시판의 컬랙션(free_board)에서 게시글을 조회합니다
        """

        board_type = board_type + "_board"

        volume = int(request.args.get("volume", default=20))
        last_post_id = request.args.get("lastPostId", default="")
        first_post_id = request.args.get("firstPostId", default="")

        if (not last_post_id) and (not first_post_id):  # 게시판에 처음 들어간 경우, 새로 고침한 경우
            total_list = list(mongodb.find(collection_name=board_type).sort([("_id", -1)]).limit(volume))

        elif last_post_id:  # 과거 게시글 불러올 때
            last_post_id = ObjectId(last_post_id)
            total_list = list(mongodb.find(
                query={'_id': {'$lt': last_post_id}}, 
                collection_name=board_type).sort([("_id", -1)]).limit(volume))
        
        elif first_post_id:  # 업데이트된 게글 불러올 때
            first_post_id = ObjectId(first_post_id)
            total_list = list(mongodb.find(
                query={'_id': {'$gt': first_post_id}}, 
                collection_name=board_type).sort([("_id", -1)]).limit(volume))
        

        # 위에서 total_list가 정해짐 
        if total_list:  # 불러올 게시글이 남아있는 경우
            if board_type == "hot_board":  # 인기게시판인 경우 
                """
                {
                    "_id"
                    "boardType"
                    "date"
                }
                """

                hot_post_list = []
                for temp_post in total_list:
                    post_id = ObjectId(temp_post["_id"])
                    board_type = temp_post["boardType"] + "_board"

                    post = mongodb.find_one(query={"_id": post_id}, collection_name=board_type)
                    post["_id"] = str(post["_id"])
                    post["date"] = str(post["date"])
                    post["image"] = get_image(post["image"], "post", "200")  
                    
                    if board_type == "secret_board":  # 비밀게시판인 경우에 author 을 None으로 변경
                        post["author"]["nickname"] = "익명"
                        
                    post["author"]["profileImage"] = []

                    hot_post_list.append(post)
                
                if first_post_id:
                    return_last_post_id = None
                else: 
                    return_last_post_id = total_list[-1]["_id"]

                print("인기게시판에 들어간 각 게시글의 정보:", hot_post_list)

                response_result = make_response({
                    "lastPostId": return_last_post_id,
                    "postList": hot_post_list
                }, 200)

            else:  # 인기게시판 이외의 게시판
                for post in total_list:
                    post["_id"] = str(post["_id"])
                    post["date"] = (post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
                    post["image"] = get_image(post["image"], "post", "200")                

                    if board_type == "secret_board":  # 비밀게시판인 경우에 author 을 None으로 변경
                        post["author"]["nickname"] = "익명"
                    
                    post["author"]["profileImage"] = []  # 비밀 게시판이거나 아니거나 게시글 리스트는 profileImage [ ]
        

                if first_post_id:
                    return_last_post_id = None
                else: 
                    return_last_post_id = total_list[-1]["_id"]

                response_result = make_response({
                    "lastPostId": return_last_post_id,
                    "postList": total_list
                }, 200)

        else:  # 불러올 게시글이 없는 경우
            response_result = make_response({
                "lastPostId": None, 
                "postList": []
            }, 200)
        
        return response_result


    def delete(self, board_type):  # 컬렉션 자체를 삭제

        result = mongodb.drop(collection_name=board_type)
        response_result = make_response({"queryStatus": result}, 200)

        return response_result



TotalSearchList = Namespace(
    "totalsearch",
    description="통합검색 관련 API"
)

@TotalSearchList.route("")
class TotalSearchControl(Resource):
    @jwt_required()
    def get(self):
        # 회원여부
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        keyword = request.args.get("key")
        volume = int(request.args.get("volume", default=5)) # 각 게시판에서 5개씩만 긁어옴
        last_post_id = request.args.get("lastPostId", default="")
        first_post_id = request.args.get("firstPostId", default="")
        standard_id = request.args.get("standardId", default="")

        board_list = ["free", "job", "secret"]
        
        print(standard_id)
        total_list = []
        for board in board_list:
            board_type = board + "_board"
            print(board_type)
            query = {
                "$or": [{"content":{"$regex":keyword}}, {"title":{"$regex":keyword}}]
                }
            
            if first_post_id:
                first_post_id = ObjectId(first_post_id)
                query["_id"] = {"$gt": first_post_id}
            
            elif last_post_id: 
                last_post_id = ObjectId(last_post_id)
                query["_id"] = {"$lt": last_post_id}

            part_list = list(mongodb.find(collection_name=board_type,query=query).sort([("_id", -1)]).limit(volume))
            print("{} part_list: {}". format(board_type, part_list))
            total_list.extend(part_list)
            print(total_list)

        total_list.sort(key=lambda x: x["_id"], reverse=True)  #_id의 처음 4부분은 시간 정보를 담고 있다.

        if total_list:  # 불러올 게시글이 있는 경우
            for post in total_list:
                post["_id"] = str(post["_id"])
                post["date"] = (post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
                post["image"] = get_image(post["image"], "post", "200")  

                if post["boardType"] == "secret":
                    post["author"]["nickname"] = "익명"
                    post["author"]["profileImage"] = []
                else:
                    post["author"]["profileImage"] = get_image(post["author"]["profileImage"], "user", "200")

            last_post_id = total_list[-1]["_id"]

        else:
            total_list = []
            last_post_id = None

        response_result = make_response({
            "lastPostId": last_post_id,
            "postList": total_list
        }, 200)

        return response_result


SearchList = Namespace(
    "search", 
    description="검색 관련 API")

@SearchList.route("/<string:board_type>")
class SearchControl(Resource):
    @jwt_required()
    def get(self,board_type):
        # 회원여부
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        keyword = request.args.get("key")
        board_type = board_type + "_board"
        volume = int(request.args.get("volume", default=20))
        last_post_id = request.args.get("lastPostId", default="")
        first_post_id = request.args.get("firstPostId", default="")
        query={"$or": [{"content":{"$regex":keyword}}, {"title":{"$regex":keyword}}]}
        standard_id = request.args.get("standardId", default="")
        print(board_type)

        if first_post_id:
            first_post_id = ObjectId(first_post_id)
            query["_id"] = {"$gt": first_post_id}
        
        elif last_post_id:
            last_post_id = ObjectId(last_post_id)
            query["_id"] = {"$lt": last_post_id}
        
        total_list = list(mongodb.find(
                collection_name=board_type,
                query=query
                ).sort([("_id", -1)]).limit(volume))


        if total_list:  # 불러올 게시글이 남아있는 경우
            for post in total_list:
                post["_id"] = str(post["_id"])
                post["date"] = (post["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
                post["image"] = get_image(post["image"], "post", "200") 

                if post["boardType"] == "secret":
                    post["author"]["nickname"] = "익명"
                    post["author"]["profileImage"] = []
                else:
                    post["author"]["profileImage"] = get_image(post["author"]["profileImage"], "user", "200")

            last_post_id = total_list[-1]["_id"]

            response_result = make_response({
                        "lastPostId": last_post_id,
                        "postList": total_list
                    }, 200)

        else: # 불러올 게시글이 없는 경우
            response_result = make_response({
                "lastPostId": None,
                "postList": []
            }, 200)

        return response_result


MessageList = Namespace(
    "messagelist",
    description="메시지 목록을 불러오는 API"
)

@MessageList.route("/<string:message_type>")  # send, receive
class MassageListControl(Resource):
    @jwt_required()
    def get(self, message_type):  # 쪽지 목록 불러오기
        """
        쪽지 리스트를 조회합니다
        """
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result
        print(user_id)
        message_field = (mongodb.find_one(query={"_id": user_id}, collection_name="user"))["message"]

        # 아직 message_type이 user db에 message field에 없으면 KeyError 발생 -> 이걸 고친건가?
        if not (message_type in message_field):  # send, receive 이외로 검색하면
            response_result = make_response({"queryStatus": "wrong massageType"})
            return response_result

        message_id_list = (mongodb.find_one(query={"_id": user_id}, collection_name="user"))["message"][message_type]
        print(message_id_list)

        # 회원활동 게시글 조회와 구조 동일
        message_list = []
        for message_id in message_id_list:
            print("개별 메시지 id : ", message_id)
            result = mongodb.find_one(query={"_id": ObjectId(message_id)}, collection_name="message")
            if result:  # 쪽지 컬랙션에 있는 경우
                result["_id"] = str(result["_id"])
                result["date"] = (result["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
                message_list.append(result)

            else:  # 쪽지 컬랙션에 없는 경우
                continue
            
        message_list.sort(key=lambda x: x["_id"], reverse=True)
        
        response_result = make_response({
            f"{message_type}List": message_list
        }, 200)

        return response_result


UserControl = Namespace(
    name="usercontrol",
    description="유저관련 기능"
)

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
        
        response_result = make_response({"userList":result}, 200)

        return response_result

    def post(self):
        """
        token block 설정 위한 block_list 컬렉션 설정
        """
        result = mongodb.create_index(standard="createdAt", collection_name="block_list", expire_time=10)
        response_result = make_response({
            "queryStatus": result
        }, 200)
        return response_result 
