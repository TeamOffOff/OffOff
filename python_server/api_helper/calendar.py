from flask import request
from pymongo import collection
from flask_restx import Resource, Namespace
from flask_jwt_extended import jwt_required, get_jwt_identity
from bson.objectid import ObjectId

from python_server.controller.filter import check_jwt
import python_server.mongo as mongo


mongodb = mongo.MongoHelper()

Calendar = Namespace('calendar', description="캘린더 관련 API")


@Calendar.route("")
class CalendarControl(Resource):
    @jwt_required
    def get(self):
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        calendar_id = request.args.get("calendar")
        calendar_info = mongodb.find_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar")

        # 순서고정

        return {"calendar": calendar_info}, 200
    
    
    @jwt_required
    def post(self):
        # 회원 확인
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403
        
        # json 받기
        request_info = request.get_json()
        del request_info["_id"]
        
        # db 저장
        calendar_id = mongodb.insert_one(data=request_info, collection_name="calendar")

        if not str(calendar_id):
            return{"queryStatus": "fail"}, 500
        
        # user 컬랙션에 참조 달기
        link_calendar = {"calendar" : str(calendar_id)}
        result = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set":link_calendar})
        
        if result.raw_result["n"] == 0:
            return{"queryStatus": "user info update fail"}, 500

        return {"queryStatus": "success"}, 200
    

    def put(self):
        """
        추가, 수정
        일부만 수정하는 경우 별도로 저장될 수도 있다..
        """
        request_info = request.get_json()  # _id, 변경할 타입, 변경/추가하는 내용



    def delete(self):
        """
        shift, saved shift 삭제? 
        + 캘린더의 삭제는 회원탈퇴할 때? 
        + 캘린더 자체를 아예 삭제할 수 있는 기능이 있나?
        """
        request_info = request.get_json()
        calendar_id = request_info["_id"]

        result = mongodb.delete_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar")
        
        if result.raw_result["n"] == 0:
            return {"queryStatus": "calendar delete fail"}, 500
        
        return{"queryStatus": "success"}, 200

