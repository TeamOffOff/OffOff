from flask import request
from flask_jwt_extended import jwt_required

import mongo as mongo
from controller.filter import check_jwt
from controller.image import *


mongodb = mongo.MongoHelper()



# 변수 추출
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


# string 으로 변환
def convert_to_string(post, *args):
    for key in args:
        post[key] = str(post[key])


# 댓글 조회 함수
def get_reply_list(post_id=None, board_type=None):
    total_list = list(mongodb.find(query={"postId": post_id},
                                   collection_name=board_type))  # 댓글은 오름차순

    for reply in total_list:
        reply["_id"] = str(reply["_id"])
        if reply["date"]:
            reply["date"] = (reply["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")

        if board_type == "secret_board_reply":  # 비밀 게시판
            reply["author"]["nickname"] = "익명"
            reply["author"]["profileImage"] = []
        
        else:  # 비밀게시판이 아닌데,
            if reply["author"]:  # author가 살아있음(탈퇴하지 않음)
                reply["author"]["profileImage"] = get_image(reply["author"]["profileImage"], "user", "200")


        if reply["childrenReplies"]:  # 대댓글이 있으면
            for children_reply in reply["childrenReplies"]: # 대댓글 하나씩 돌면서 author profileImage 인코딩
                
                if board_type == "secret_board_reply":  # 비밀 게시판
                    children_reply["author"]["nickname"] = "익명"
                    children_reply["author"]["profileImage"] = []
                
                else: # 비밀게시판이 아닌데,
                    if children_reply["author"]:  # author가 살아있음(탈퇴하지 않음)
                        children_reply["author"]["profileImage"] = get_image(children_reply["author"]["profileImage"], "user", "200")

    return total_list