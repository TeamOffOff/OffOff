from flask import request
from flask_jwt_extended.utils import get_jwt
from flask_jwt_extended import jwt_required, get_jwt_identity

import mongo as mongo

mongodb = mongo.MongoHelper()

"""duplication, blocklist, ownership filter"""


# 중복확인 함수 => 데코레이터 고민 중
def check_duplicate(key, target):
    if mongodb.find_one(query={key: target}, collection_name="user"):
        return {
                   "queryStatus": "already exist"
               }, 409


# blocklist에 있는지 체크하는 함수 (jwt_required 데코레이터가 있는 모든 곳에 있어야함) => 라이브러리 내에 있는 데코레이터 아님
def check_jwt():
    user_id = get_jwt_identity()
    print(user_id)
    jti = get_jwt()["jti"]
    result = mongodb.find_one(query={"_id": jti}, collection_name="block_list")  # 없으면 null(None) 반환

    if (not user_id) or result:
        # user_id 가 없거나 block로 설정되어 있는 경우
        return False
    else:
        return user_id

"""
ownership_required 를 하면 jwt_required 안 해도 된다
"""

# 수정, 삭제, 접근 시 작성자 확인
def ownership_required(func):
    @jwt_required()
    def wrapper(self):
        request_info = request.get_json()

        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        if "author" in request_info:  # 삭제, 수정은 author 넘겨받음
            author = (request.get_json())["author"]

            if author == user_id:
                result = func(self)
                return result
            else:
                return {"queryStatus": "작성자가 아닙니다"}, 403

        else:  # 게시글, 댓글 좋아요
            result = func(self)
            return result

    return wrapper