from flask import request
from pymongo import collection
from flask_restx import Resource, Namespace
from flask_jwt_extended import jwt_required, get_jwt_identity
from bson.objectid import ObjectId

from controller.filter import check_jwt
import mongo as mongo


mongodb = mongo.MongoHelper()

Calendar = Namespace('calendar', description="캘린더 관련 API")


@Calendar.route("")
class CalendarControl(Resource):
    @jwt_required()
    def get(self):
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        calendar_id = request.args.get("id")
        print(calendar_id)
        calendar_info = mongodb.find_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar")
        calendar_info["_id"] = str(calendar_info["_id"])

        # 순서고정

        return calendar_info, 200
    
    
    @jwt_required()
    def post(self):
        print("post")
        # 회원 확인
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403
        print(user_id)

        # json 받기
        request_info = request.get_json()
        print()
        del request_info["_id"]
        
        # db 저장
        calendar_id = mongodb.insert_one(data=request_info, collection_name="calendar")

        if not str(calendar_id):
            return{"queryStatus": "fail"}, 500
        
        # user 컬랙션에 참조 달기
        link_calendar = {"calendar" : str(calendar_id)}
        result = mongodb.update_one(query={"_id": user_id}, collection_name="user", modify={"$set":link_calendar})
        # user collection에 calendar field 리스트 형태로 바꾸기

        if result.raw_result["n"] == 0:
            return{"queryStatus": "user info update fail"}, 500

        return {"queryStatus": "success"}, 200
    

    def put(self):
        """
        shift
         {
            "id": "string",
            "title": "string",
            "textColor": "string",
            "backgroundColor": "string",
            "startDate": "string",
            "endDate": "string"
        }
        saved shift
        {
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
        request_info = request.get_json()
        """
        "_id": string,
        "method": update(수정), post(추가), delete(삭제),
        "field": shift, saved shift  --> 이건 shift 필드 유무로 가릴 수 있으므로 없어도 됨
        "content": {
            object
        }

        """
        calendar_id = request_info["_id"]
        operator = request_info["method"]
        field = request_info["field"]
        content = request_info["content"]
        

        if operator == "update":
            shift_id = content["id"]
            operator = "$set"
            result = mongodb.update_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar", modify={operator:{f"{field}.$[elem]":content}}, array_filters=[{"elem.id":shift_id}])
            if result.raw_result["n"] == 0:
                return {"queryStatus": "calendar update fail"}, 500
            return {"queryStatus": "success"}, 200
            
            # 체크할것
            # update_status = mongodb.update_one(query={"_id": ObjectId(reply_id)}, collection_name=board_type, modify={"$inc":{"subReplies.$[subreply].likes": modified_like}},upsert=False, array_filters=[{"subreply.content":content, "subreply.date":date}])
        
        elif operator == "post":
            operator = "$addToSet"
        
        elif operator == "delete":
            operator = "$pull"
        
        result = mongodb.update_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar", modify={operator:{field: content}})

        if result.raw_result["n"] == 0:
            return {"queryStatus": "calendar update fail"}, 500
            
        return {"queryStatus": "success"}, 200

    @jwt_required()
    def delete(self):
        """
        캘린더 초기화
        """
        # 회원 확인
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403
        print(user_id)

        request_info = request.get_json()
        calendar_id = request_info["_id"]

        ownership= mongodb.find_one(query={"_id": user_id}, collection_name="user")["calendar"]

        if not(calendar_id in ownership):
            return {"queryStatus": "wrong access"}, 403


        result = mongodb.delete_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar")
        
        # user collection에서 calendar field에서 pull

        if result.raw_result["n"] == 0:
            return {"queryStatus": "calendar delete fail"}, 500
        
        return{"queryStatus": "success"}, 200

