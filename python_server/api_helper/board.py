from flask import request
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId

import mongo

mongodb = mongo.MongoHelper()

BoardList = Namespace(
    name="boardlist",
    description="게시판목록을 불러오는 API")

PostList = Namespace(
    name="postlist",
    description="게시글목록을 불러오는 API")


@BoardList.route("/")
# 사용자가 커뮤니티 탭을 클릭하는 경우
class BoardListControl(Resource):
    """
    <DB에 구조>
    board_list 라는 컬랙션에
    {
        "name" : "자유게시판",
        "icon" : "image url"
    },
    {
        "name" : "비밀게시판",
        "icon" : "image url"
    }
    """

    def get(self):
        """
        DB > board_list 컬랙션에서 게시판을 조회합니다
        """
        cursor = mongodb.find(collection_name="board_list", projection_key={"_id": 0})
        
        board_list = []
        for doc in cursor:
            board_list.append(doc)

        return {
            "board": board_list
        }


@PostList.route("/")
# 사용자가 특정 게시판을 클릭하는 경우
class PostListControl(Resource):
    """
    input shape

    {
        "board_type": "free",
        "page_size": 20,
        "last_content_id": "" or "last_content_id"
    }
    """
    def get(self):
        """
        DB > 해당 게시판의 컬랙션(free_board)에서 게시글을 조회합니다
        """
        try:
            board_info = request.get_json()
           

            board_type = board_info["board_type"] + "_board"  

            last_content_id = None
            if board_info["last_content_id"]:
                last_content_id = ObjectId(board_info["last_content_id"])


            page_size = board_info["page_size"]

            if last_content_id is None:  # 게시판에 처음 들어간 경우
                cursor = mongodb.find(collection_name=board_type).sort([("_id", -1)]).limit(page_size)
            else:  # 스크롤 하는 경우
                cursor = mongodb.find(query={'_id': {'$lt': last_content_id}}, collection_name=board_type).sort(
                    [("_id", -1)]).limit(page_size)
 

            post_list = []
            for doc in cursor:
                doc["_id"] = str(doc["_id"])
                post_list.append(doc)

            last_content_id = post_list[-1]["_id"]

            return {
                "last_content_id": last_content_id,
                "post_list": post_list
            }
            
        except IndexError:
            return {
                "last_content_id": None,
                "post_list": None
            }