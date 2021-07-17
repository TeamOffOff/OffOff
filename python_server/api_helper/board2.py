#커뮤니티 탭 클릭 ->/boardlist로 연결되게 -> 게시판 목록(컬랙션 : board_list)
#게시판 목록 중 -> 자유게시판 클릭 -> board_type 넘겨주면서 /postlist로 연결되게 -> 우선 20개 먼저 보내줌 (컬랙션 : 개별 board_type이름)
#자유게시판에서 스크롤 -> board_type, 마지막 받은 _id 넘겨주면서 /postlist로 연결되게 -> 그 다음 20개 보내줌

from flask import request
from flask_restx import Resource, Namespace
from bson import json_util
import json
import mongo
from bson.objectid import ObjectId

mongodb = mongo.MongoHelper()


BoardList = Namespace("boardlist") #커뮤니티 텝을 클릭하는 경우 게시판 리스트를 보여주고
PostList = Namespace("postlist") #특정 게시판을 클릭하는 경우 게시글 리스트를 보여준다


@BoardList.route("/") 
#사용자가 커뮤니티 텝을 클릭하는 경우 여기로 오세요
class BoardListControl(Resource):
    def get(self):
        # board_list = request.args.get("board_list")
        # board_list은 사용자, 클라이언트에게 입력받는 값이 아니라 우리가 데이터베이스에 미리 저장해놓는 것! 따라서 request할 필요없다!

        cursor = mongodb.find(collection_name="board_list",finding_key={"_id":0} )
        #board_list이라는 컬렉션을 찾아서 모든 다큐멘트(즉 board_list)를 불러와라


        board_list = [x for x in cursor]
        #불러온 다큐멘트들을 리스트형태로 바꿔줌

        return board_list #리스트 형태로 반환되어도 되나요? 


@PostList.route("/") 
#사용자가 특정 게시판을 클릭하는 경우 여기로 오세요
class PostListControl(Resource):
    def get(self, page_size=20, last_id=None):  #이 파라미터는 어떻게 전달되는걸까?
        #프론트에서 한 번에 불러올 게시글 리스트 갯수인 page_size를 넘겨주고 (default = 20), 
        #우리가 리턴해주는 last_id도 넘겨줘야함 (2번째부터)
        board_type_post = str(request.args.get("board_type_post"))
        #free_post (자유게시판 컬랙션 이름)
        #프론트에서 넘겨주는 board_type_post(name)의 value 받기 => board_type_post변수에 저장
        self.last_id = ObjectId(last_id)
        
        if last_id is None:
            #처음 게시판에 들어간 경우(마지막 다큐멘트의 아이디가 없음)
            cursor = mongodb.find(collection_name=board_type_post).sort([("_id", -1)]).limit(page_size)
            #최신순으로 정렬해서(내림차순) 그냥 갯수만큼만 불러오면 됨
        else: 
            #사용자가 스크롤을 끝까지 내려서 새로운 리스트를 받아오는 경우
            cursor = mongodb.find(query={'_id': {'$lt': self.last_id} }, collection_name=board_type_post).sort([("_id", -1)]).limit(page_size)
            #과거의 데이터를 불러오는 거니까 _id가 더 작음(시간이 더 빠르니까)
            #과거의 데이터들 중에서 최신순으로 정렬해서 갯수만큼 불러옴
            #최신순일 수록 _id가 크고 오래될 수록 _id가 작다
        
        
        if not cursor:
            #남은 다큐멘트가 없는 경우
            return None, None
        
        post_list = []
        for doc in cursor :
            doc["_id"]=str(doc["_id"])
            post_list.append(doc)
        
        last_id = post_list[-1]["_id"]

        return {
            "last_id" : last_id, 
            "post_list" : post_list
        }
            
            
        # up이 아래에서 위로 -> 새로운 걸 불러오는 것
        # down이 위에서 아래로 -> 봤던 걸 불러오는 것     