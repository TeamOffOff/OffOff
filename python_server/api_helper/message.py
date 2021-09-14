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
Collection : message
{
    "_id": ObjectId,
    "send": user_id  # nickname 어떻게 할지 논의해야함
    "receive": user_id,
    "date": datetime
    "content": string,
    "post": {
        "post_id": string,
        "post_title": string
    },
    "delete": {
        "send": False,
        "receive": False
    }
}
"""

"""
Collection : user
{
    "message":{
        "send": [],
        "recieve": []
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

        # message collection에 저장
        message_id = mongodb.insert_one(data=request_info, collection_name="message")

        # sender, reciever 변수 저장
        for user in ("send", "receive"):
            user = request_info[user]
            making_reference =MakeReference(board_type="user", user=user)
            result = making_reference.link_activity_information_in_user(field=f"message.{user}", post_id=message_id, operator="$addToSet")
            if (result.raw_result["n"] == 0):
                return {"queryStatus": "update activity fail"}, 500

                
        # 메시지 보내고 난 다음 해당 게시글 페이지에 남아있음을 가정 -> 메시지 보낸 걸 성공했다는 것만 알림
        return {"queryStatus": "send massage success"}, 200


    @jwt_required()
    def get(self):  
        # 리펙토링 필요!!!!
        user_id = check_jwt()
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        message_id = request.args.get("msgId")
        user = request.args.get("user") # send, recieve
        
        # check_jwt()로 얻는 user_id가 주고 받았던 당시와 달라질 일은 없음 
        # 삭제했던 걸 url을 입력해서 들어가는 사람도 있을 수 있음 => true, false로 확인하면 됨
        # check_jwt()로 얻은 user_id 의 message에 해당 message_id가 있는지 확인하는 방향으로 확인할 수도 있지만 그렇게 되면 2개의 collection을 확인하게 됨

        message = mongodb.find_one(query={"_id": ObjectId(message_id)}, collection_name="message")  # send, receive 둘 다 삭제한 경우
        if not message:
            return {"queryStatus": "not found"}, 404
        
        whether_to_delete = message["delete"][user]  # 삭제하면 True 상대방은 삭제 하지 않았지만 자신은 삭제했었던 경우
        if whether_to_delete:
            return{"queryStatus": "not found"}, 404
        
        check_user = message[user]
        if user_id != check_user:  # 접근한 유저(user_id)와 기록되어있는 user가 다른경우
            return{"queryStatus": "wrong access"}, 403


        message["_id"] = str(message["_id"])
        message["date"] = (message["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")

        return message, 200


    @jwt_required()  # 로그인 안 되어있는 경우 여기에서 걸러짐
    def delete(self):
        user_id = check_jwt()  #blocklist 토큰 걸러내기
        if not user_id:
            return {"queryStatus": "wrong Token"}, 403

        total = ['send', 'receive']
        message_id = request.args.get("msgId")
        user = request.args.get("user") # send, recieve
        other = (total.remove(user))[0]

        message = mongodb.find_one(query={"_id": ObjectId(message_id)}, collection_name="message")  # 둘 다 삭제해서 db에서 못 찾은 경우
        if not message:
            return {"queryStatus": "not found"}, 404

        whether_to_delete = message["delete"][user]  # 삭제하면 True 상대방은 삭제 하지 않았지만 자신은 삭제했었던 경우
        if whether_to_delete:
            return{"queryStatus": "not found"}, 404
        
        check_user = message[user]
        if user_id != check_user:  # 접근한 유저와 기록된 유저가 다른 경우
            return{"queryStatus": "wrong access"}, 403


        # user collection에서 message id 삭제
        making_reference = MakeReference(board_type="user", user=user_id)
        result = making_reference.link_activity_information_in_user(field=f'message.{user}', post_id=message_id, operator="$pull")
        if (result.raw_result["n"] == 0):
            return {"queryStatus": "update activity fail"}, 500
        
        if message["delete"][other]:  # 상대방이 이미 삭제한 경우 (True)
            result = mongodb.delete_one(query={"_id":message_id}, collection_name="message")
        else:
            # message collection에서 True로 변경
            # $set 제대로 작동하는지 확인하기
            result = mongodb.update_one(query={"_id":message_id}, collection_name="message", modify={"set": {f"delete.{user}": True}})

        if result.raw_result["n"] == 0:
            return {"queryStatus": "delete message fail"}, 500
        
        return{"queryStatus": "delete success"}, 200






        

