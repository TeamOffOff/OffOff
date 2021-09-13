from pymongo import message
from controller.reference import MakeReference
from flask import request
from flask_restx import Resource, Namespace
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from controller.filter import check_jwt, ownership_required

# 보낸 쪽지 / 받은 쪽지
"""
{
    "_id": ObjectId,
    "sender": id,
    "reciever": id,
    "date": datetime
    "content": string,
    "post": {
        "post_id": string,
        "post_title": string
    },
    "whethertodelete": {
        "sender": False,
        "reciever": False
    }
}
if sender check sent message box,
client send api for getting list
<way1> in that time, back should check if sender in whethertodelete is False,
so if it is False, then back add that message in the list for client
<way2> in user collection, a document that is about one User should have field for message API
in that field, it contains message_id for finding massage. we can use that id

if someone delete message,
client send api for deleting it
in that time, back should check if all in whethertodelete is True.
if all is True, then back totally delete that data in the database
"""

import mongo 
mongodb = mongo.MongoHelper()

Message = Namespace("message", description="메시지 관련 API")

@Message.route('')
class MassageControl(Resource):
    def post(self):
        # json 받기
        request_info = request.get_json()

        #_id 삭제
        del request_info["id"]

        # datetime 추가
        request_info["date"] = datetime.now()

        # sender, reciever 변수 저장
        sender = request_info["sender"]
        reciever = request_info["reciever"]

        # message collection에 저장
        message_id = mongodb.insert_one(data=request_info, collection_name="message")

        # user collection / sender에 message_id 추가
        making_reference = MakeReference(board_type="user", user=sender)
        result1 = making_reference.link_activity_information_in_user(field="message.send", post_id=message_id, operator="$addToSet")

        # user collection / reciever에 message_id 추가
        making_reference =MakeReference(board_type="user", user=reciever)
        result2 = making_reference.link_activity_information_in_user(field="message.recieve", post_id=message_id, operator="$addToSet")
        

        if (result1.raw_result["n"] == 0) or (result2.raw_result["n"] == 0):
            return {"queryStatus": "update activity fail"}, 500
        else:  # 메시지 보내고 난 다음 해당 게시글 페이지에 남아있음을 가정
            return {"queryStatus": "send massage success"}, 200

    def get(self):
        pass

    def delete(self):
        pass


        