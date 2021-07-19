# 커뮤니티 탭 클릭 -> api 날림 -> 게시판 목록(컬랙션 : board_list)
# 게시판 목록 중 -> 자유게시판 클릭 -> board_type 넘겨주면서 api 날림 -> 우선 20개 먼저 보내줌 (컬랙션 : free_board)
# 자유게시판에서 스크롤 -> board_type, page_size, last_content_id 넘겨주면서 api 날림-> 그 다음 20개 보내줌

from flask import request
from flask_restx import Resource, Namespace
import mongo
from bson.objectid import ObjectId

mongodb = mongo.MongoHelper()

BoardList = Namespace(
    name="boardlist",
    description="게시판목록을 불러오는 API")
# 커뮤니티 탭을 클릭하는 경우 게시판목록을 전달

PostList = Namespace(
    name="postlist",
    description="게시글목록을 불러오는 API")
# 특정 게시판을 클릭하는 경우 게시글목록을 전달

@BoardList.route("/")
# 사용자가 커뮤니티 탭을 클릭하는 경우
class BoardListControl(Resource):
    def get(self):
        """
        DB 에서 게시판목록을 찾아 전달
        
        <DB에 구조>
        board_list 라는 컬랙션에
        {"name" : "자유게시판",
        "icon" : "image url"},
        {"name" : "비밀게시판",
        "icon" : "image url"}
        """
        cursor = mongodb.find(collection_name="board_list", projection_key={"_id": 0})
        
        board_list = []
        for doc in cursor:
            board_list.append(doc)
        # 불러온 다큐멘트들을 리스트형태로 바꿔줌

        return {
            "board": board_list
        }


@PostList.route("/")
# 사용자가 특정 게시판을 클릭하는 경우
class PostListControl(Resource):
    def get(self):
        """
        DB > 해당 게시판의 컬랙션(free_board)에서 게시글목록 찾아 전달

        uri 에는 다른 정보 안 받고
        json 으로 
        {"board_type": "free",
        "page_size": 20,
        "last_content_id": "" or "last_content_id"}
        받음
        """
        try:
            board_info = request.get_json()
           

            board_type = board_info["board_type"] + "_board"  
            # 클라이언트에서는 "board_type" : "free" => 서버가 찾을 때는 "board_type" : "free_board"

            last_content_id = None
            if board_info["last_content_id"]:
                last_content_id = ObjectId(board_info["last_content_id"])


            page_size = board_info["page_size"]

            if last_content_id is None:
                # 처음 게시판에 들어간 경우(last_content_id를 빈문자열로 보냄 "")
                cursor = mongodb.find(collection_name=board_type).sort([("_id", -1)]).limit(page_size)
                # 최신순으로 정렬해서(내림차순) page_size 개의 document 를 불러옴
            else:
                # 사용자가 스크롤을 내려서 새로운 리스트를 받아오는 경우
                cursor = mongodb.find(query={'_id': {'$lt': last_content_id}}, collection_name=board_type).sort(
                    [("_id", -1)]).limit(page_size)
                # 과거의 데이터를 불러오는 거니까 _id가 더 작음(시간이 더 빠르므로)
                # 과거의 데이터들 중에서 최신순으로 정렬해서 불러옴
                # 최신순일 수록 _id가 크고 오래될 수록 _id가 작다

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
            # 남은 document 가 없는 경우 IndexError 발생(예외처리)
            return {
                "last_content_id": None,
                "post_list": None
            }