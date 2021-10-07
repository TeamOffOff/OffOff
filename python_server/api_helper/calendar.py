from logging import disable, shutdown
from flask import request
from pymongo import collection
from flask_restx import Resource, Namespace
from flask_jwt_extended import jwt_required, get_jwt_identity
from bson.objectid import ObjectId

from controller.calendar import calendar_post_or_delete, calendar_update
from controller.filter import check_jwt
import mongo as mongo


mongodb = mongo.MongoHelper()

Calendar = Namespace('calendar', description="캘린더 관련 API")
Shift = Namespace("shift", description="Shift 관련 API")
SavedShift = Namespace("savedshift", description="SavedShift 관련 API")


@Calendar.route("")
class CalendarControl(Resource):
    @jwt_required()
    def get(self):
        # 자기가 캘린더인지 확인하는 과정 필요
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        calendar_id = request.args.get("id")
        print(calendar_id)
        calendar_info = mongodb.find_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar")
        calendar_info["_id"] = str(calendar_info["_id"])

        # 순서고정

        return calendar_info, 200


@Shift.route("")
class ShiftControl(Resource):
    @jwt_required()
    def post(self):
        """
            "_id": string,
            "shift": {
                "id": "string",
                "title": "string",
                "textColor": "string",
                "backgroundColor": "string",
                "startDate": "string",
                "endDate": "string"
            }
        """
        # 회원 확인
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403
        print(user_id)

        # 유저와 calendar_id 가 매칭되는지 확인하는 과정 넣을까 말까?


        request_info = request.get_json()
        calendar_id = request_info["_id"]

        # 이미 캘린더를 생성한 적이 있는 경우
        if calendar_id:
            field = "shift"
            operator = "$addToSet"
            
            result = calendar_post_or_delete(field=field, operator=operator)
            
            if result.raw_result["n"] == 0:
                    return {"queryStatus": "shift update fail"}, 500
            return {"queryStatus": "success"}, 200
        
        # 캘린더를 생성한 적이 없는 경우
        shift = request_info["shift"]
        data = {
            "shift": [shift],
            "savedShift":[]
        }

        # db 저장
        calendar_id = mongodb.insert_one(data=data, collection_name="calendar")

        if not str(calendar_id):
            return{"queryStatus": "fail"}, 500
        
        # user 컬랙션에 참조 달기
        link_calendar = {"calendar" : str(calendar_id)}
        result = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set":link_calendar})

        if result.raw_result["n"] == 0:
            return{"queryStatus": "user info update fail"}, 500

        return {
            "queryStatus": "success",
            "calendarId": str(calendar_id)
        }, 200


    @jwt_required()
    def put(self):
        """
            "_id": string,
            "shift": {
                "id": "string",
                "title": "string",
                "textColor": "string",
                "backgroundColor": "string",
                "startDate": "string",
                "endDate": "string"
            }
        """
        
        field = "shift"
        operator = "$set"

        result = calendar_update(field=field, operator=operator)

        if result.raw_result["n"] == 0:
                return {"queryStatus": "shift update fail"}, 500
        return {"queryStatus": "success"}, 200
        
    @jwt_required()
    def delete(self):
        """
            "_id": string,
            "shift": {
                "id": "string",
                "title": "string",
                "textColor": "string",
                "backgroundColor": "string",
                "startDate": "string",
                "endDate": "string"
            }
        """
        
        field = "shift"
        operator = "$pull"

        result = calendar_post_or_delete(field=field, operator=operator)

        if result.raw_result["n"] == 0:
                return {"queryStatus": "shift update fail"}, 500
        return {"queryStatus": "success"}, 200


@SavedShift.route("")
class ShiftControl(Resource):
    # user_id뽑아내서 calendar_id가 있는지 확인하는 과정 필요
    @jwt_required()
    def post(self):
        """
        {
            "_id": string,
            "savedShfit": {
                "id": "string",
                "date": "string",
                "shift": {
                    "id": "string",
                    "title": "string",
                    "textColor": "string",
                    "backgroundColor": "string",
                    "startDate": "string",
                    "endDate": "string"
            }
        }
        """

        
        field = "savedShift"
        operator = "$addToSet"

        result = calendar_post_or_delete(field=field, operator=operator)

        if result.raw_result["n"] == 0:
                return {"queryStatus": "savedShift update fail"}, 500
        return {"queryStatus": "success"}, 200

    @jwt_required()
    def put(self):
        """
        {
            "_id": string,
            "savedShift": {
                "id": "string",
                "date": "string",
                "shift": {
                    "id": "string",
                    "title": "string",
                    "textColor": "string",
                    "backgroundColor": "string",
                    "startDate": "string",
                    "endDate": "string"
            }
        }
        """

        field = "savedShift"
        operator = "$set"

        result = calendar_update(field=field, operator=operator)

        if result.raw_result["n"] == 0:
                return {"queryStatus": "savedShift update fail"}, 500
        return {"queryStatus": "success"}, 200
        
    @jwt_required()
    def delete(self):
        """
            "_id": string,
            "savedShift": {
                "id": "string",
                "date": "string",
                "shift": {
                    "id": "string",
                    "title": "string",
                    "textColor": "string",
                    "backgroundColor": "string",
                    "startDate": "string",
                    "endDate": "string"
            }
        }
        """
        
        field = "savedShift"
        operator = "$pull"

        result = calendar_post_or_delete(field=field, operator=operator)
        
        if result.raw_result["n"] == 0:
                return {"queryStatus": "savedShift update fail"}, 500
        return {"queryStatus": "success"}, 200