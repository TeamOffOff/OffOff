#게시판 목록 -> 자유게시판 클릭 -> /board로 연결되게
#자유게시판에서 스크롤 -> page체크해서 /board로 연결되게
from flask import request
from flask_restx import Resource, Namespace

import mongo

mongodb = mongo.MongoHelper()
Board = Namespace("board")

@Board.route("/board") 
class ListControl(Resource) :
    def get(self, page_size, last_id=None) : 
        #프론트에서 한 번에 불러올 게시글 리스트 갯수인 page_size를 넘겨주고, 
        #우리가 리턴해주는 last_id도 넘겨줘야함 (2번째부터)
        board_type = request.args.get("borad_type") #프론트에서 넘겨주는 board_type 받기
        
        if last_id is None :
            #처음 게시판에 들어간 경우(마지막 다큐멘트의 아이디가 없음)
            cursor = mongodb.find(collection_name = board_type).sort({"_id" : -1}).limit(page_size) #최신순으로 정렬해서 그냥 갯수만큼만 불러오면 됨
        else : 
            #사용자가 스크롤을 끝까지 내려서 새로운 리스트를 받아오는 경우
            #과거의 데이터를 불러오는 거니까 _id가 더 작음(시간이 더 빠르니까)
            #최신순일 수록 _id가 크고 오래될 수록 _id가 작다
            cursor = mongodb.find(query = {'_id' : {'$lt' : last_id} }, collection_name = board_type).sort({"_id" : -1}).limit(page_size)
        
        #불러온 다큐멘트들을 리스트형태로 바꿔줌
        post_list = [x for x in cursor]

        if not post_list :
            #남은 다큐멘트가 없는 경우
            return None, None
        
        #해당 리스트의 제일 마지막 요소의 _id값을 받아와야함
        last_id = post_list[-1]['_id']

        return post_list, last_id
        
        

