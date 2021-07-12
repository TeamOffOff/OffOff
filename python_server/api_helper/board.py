#게시판 목록 -> 자유게시판 클릭 -> /board로 연결되게
#자유게시판에서 스크롤 -> page체크해서 /board로 연결되게
from flask import request
from flask_restx import Resource, Namespace

import mongo

mongodb = mongo.MongoHelper()
Board = Namespace("board")

@Board.route("/board") 
class ListControl(Resource) :
    def get(self) : #content_id를 삭제해야하는 거아닌가 ? #게시판 별로 collection이 따로 있는거지?
        board_type = request.args.get("borad_type") #프론트에서 넘겨주는 board_type 받기
        page = request.args.get("page", default=1, type=int) #페이지를 넘기는 방식으로 구현 : 게시판 들어왔을 때는 1부터 시작 -> 사용자 화면에서 바닥에 닿으면 +1해서 넘겨주기
        # post_count = mongodb.find(collection_name = board_type).count() #총 게시물 갯수
        
        #사용자가 위에서 아래로 스크롤하면 이전에 봤던 페이지로 인식해서 그걸 넘겨주고 (page는 -1)
        #사용자가 아래에서 위로 스크롤하면 새로운 페이지를 불러온다고 인식해서 그걸 넘겨줌 (page는 +1)
        post_list = mongodb.find(collection_name = board_type).skip((page-1)*10).limit(10) #스킵할 건 하고(skip) 갯수제한해서(limit) 불러옴 : 10개씩 보여주는 경우
        #db.collection_name.find({}) 해당 컬렉션에 있는 모든 Document를 불러옴
    
        return post_list, page #일단 이 함수가 실행되면 page값을 리턴해주는 걸로
        

