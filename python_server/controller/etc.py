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

        # 비밀게시판인 경우에 댓글 author 을 None으로 변경
        if board_type == "secret_board_reply":
            reply["author"] = None

        # 댓글에 있는 author의 profileImage가 있는 경우 base64로 인코딩
        if reply["author"]: #secret인 경우 None임
            if reply["author"]["_id"]: #탈퇴한 경우 _id가 None임
                if reply["author"]["profileImage"]: #secret도 아니고 탈퇴한 경우도 아닌데, profileImage가 있는 경우
                    reply["author"]["profileImage"] = get_image(reply["author"]["profileImage"], "user", "200")

        if reply["childrenReplies"]:  # 대댓글이 있으면
            for children_reply in reply["childrenReplies"]: # 대댓글 하나씩 돌면서 author profileImage 인코딩
                
                # 비밀게시판인 경우에 대댓글 author 을 None으로 변경
                if board_type == "secret_board_reply":
                    children_reply["author"] = None

                # 대댓글에 있는 author의 profileImage가 있는 경우 base64로 인코딩
                if children_reply["author"]: #secret인 경우 None임
                    if children_reply["author"]["_id"]: #탈퇴한 경우 _id가 None임
                        if children_reply["author"]["profileImage"]: #secret도 아니고 탈퇴한 경우도 아닌데, profileImage가 있는 경우
                            children_reply["author"]["profileImage"] = get_image(children_reply["author"]["profileImage"], "user", "200")

    return total_list