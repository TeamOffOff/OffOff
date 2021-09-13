from pymongo import message
from controller.reference import MakeReference
from flask import request
from flask_restx import Resource, Namespace
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from controller.filter import check_jwt, ownership_required
from bson.objectid import ObjectId


# 보낸 쪽지 / 받은 쪽지
"""
{
    "_id": ObjectId,
    "from": user_id,
    "to": user_id,
    "date": datetime
    "content": string,
    "post": {
        "post_id": string,
        "post_title": string
    },
    "delete": {
        "sender": False,
        "receiver": False
    }
}
"""



import mongo 
mongodb = mongo.MongoHelper()

Message = Namespace("message", description="메시지 관련 API")

@Message.route('')
class MassageControl(Resource):
    @jwt_required()
    def post(self):  # 회원인지 확인
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403
        
        # json 받기
        request_info = request.get_json()

        #_id 삭제
        del request_info["id"]

        # datetime 추가
        request_info["date"] = datetime.now()

        # sender, reciever 변수 저장
        sender = request_info["from"]  # 회원정보가 수정된 경우 sender, reciever 이름은 그 전 그대로? 새롭게 업데이트 해야하나?
        receiver = request_info["to"]

        # message collection에 저장
        message_id = mongodb.insert_one(data=request_info, collection_name="message")

        # user collection / sender에 message_id 추가
        making_reference = MakeReference(board_type="user", user=sender)
        result1 = making_reference.link_activity_information_in_user(field="message.send", post_id=message_id, operator="$addToSet")

        # user collection / reciever에 message_id 추가
        making_reference =MakeReference(board_type="user", user=receiver)
        result2 = making_reference.link_activity_information_in_user(field="message.recieve", post_id=message_id, operator="$addToSet")
        

        if (result1.raw_result["n"] == 0) or (result2.raw_result["n"] == 0):
            return {"queryStatus": "update activity fail"}, 500
        else:  # 메시지 보내고 난 다음 해당 게시글 페이지에 남아있음을 가정
            return {"queryStatus": "send massage success"}, 200


    @jwt_required()
    def get(self):  
        # 리펙토링 필요!!!!
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        message_id = request.args.get("msgId")
        who = request.args.get("who") # sender, reciever
        
        # check_jwt()로 얻는 user_id가 주고 받았던 당시와 달라질 일은 없음 
        # 삭제했던 걸 url을 입력해서 들어가는 사람도 있을 수 있음 => true, false로 확인하면 됨
        # check_jwt()로 얻은 user_id 의 message에 해당 message_id가 있는지 확인하는 방향으로 확인할 수도 있지만 그렇게 되면 2개의 collection을 확인하게 됨

        message = mongodb.find_one(query={"_id": ObjectId(message_id)}, collection_name="message")
        if not message:
            return {"queryStatus": "not found"}, 404
            
        sender = message["from"]
        sender_whether_to_delete = message["delete"]["sender"]  # 삭제하면 True
        receiver = message["to"]
        receiver_whether_to_delete = message["delete"]["receiver"]
        
        if who == "sender":
            if (user_id != sender) or (sender_whether_to_delete):
                return{"queryStatus": "wrong access"}, 403
        elif who == "reciever":
            if (user_id != receiver) or (receiver_whether_to_delete):
                return{"queryStatus": "wrong access"}, 403


        message["_id"] = str(message["_id"])
        message["date"] = (message["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")
        return message, 200


    @jwt_required()  # 로그인 안 되어있는 경우 여기에서 걸러짐
    def delete(self):
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        message_id = request.args.get("msgId")
        who = request.args.get("who") # sender, reciever
        
        # check_jwt()로 얻는 user_id가 주고 받았던 당시와 달라졌을 수 있음
        # 삭제했던 걸 url을 입력해서 들어가는 사람도 있을 수 있음
        # check_jwt()로 얻은 user_id 의 message에 해당 message_id가 있는지 확인하는 방향으로 해야함
        result = mongodb.find_one(query={"_id": user_id}, collection_name="user", projection_key={"message":True, "_id":False})
        if who == "sender":
            if not (message_id in result["message"]["send"]):
                return{"queryStatus": "Wrong access"}, 403
        else:
            if not (message_id in result["message"]["recieve"]):
                return{"queryStatus": "Wrong access"}, 403

        # user collection에서 message id 삭제

        # message collection에서 True로 변경


        # 둘 다 True 인지 확인하고 db에서 삭제



        

