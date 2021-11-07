from flask import request
from flask_jwt_extended import jwt_required

import mongo as mongo
from controller.filter import check_jwt

mongodb = mongo.MongoHelper()


# # 순서 고정 함수
# def fix_index(target, key):
#     real = {}
#     for i in key:
#         real[i] = target[i]

#     return real

# """
# fix_index : ver2
# def fix_index(target, *args):
#     real = {}
#     if not args:
#         args = target.keys()
#     print(args)
#     for i in args:
#         if type(target[i]) is dict:
#             temp = {}
#             for j in target[i]:
#                 temp[j] = target[i][j]
#             real[i] = temp
#         else:
#             real[i] = target[i]
#     return real
# """


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

    return total_list