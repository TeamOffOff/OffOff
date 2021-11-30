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
