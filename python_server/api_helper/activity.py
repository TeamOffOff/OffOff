from flask import request
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId

import jwt

import mongo

from .utils import SECRET_KEY, ALGORITHM


mongodb = mongo.MongoHelper()

Activity = Namespace(name="activity", description="유저 활동 관련 API")

@Activity.route('')
class ActivityControl(Resource):
    """
    공감, 스크랩, 댓글, 작성글
    """
    def put(self):
        header = request.headers.get("Authorization")  # 이 회원의 활동정보 변경
        new_activity_info = request.get_json()  
        """
        {
            "like" : ["content_id", "free"]
        } 
        """

        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)
        
        past_activity = mongodb.find_one(query={"id": token_decoded["id"]}, collection_name="user", projection_key={'_id': 0, "activity": 1})
        """
        {
         "activity" : {
           "likes" : [["content_id", "board_type"], ["content_id", "board_type"]],
           "posts" : [[], []]
        }
        """
        # temp = [] 
        for key in new_activity_info:
            # temp.append(key)
            past_activity["activity"][key].insert(0,new_activity_info[key])
        
        result = mongodb.update_one(query={"id": token_decoded["id"]}, collection_name="user", modify={"$set" : past_activity})

        if result.raw_result["n"] == 1:
            return {"query_status": "활동을 저장했습니다"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500



    def get(self):  # 회원활동 탭에서 보여지는 정보
        """
        사용자 활동과 관련된 게시글 보여주기
        /activity?activity-type=likes
        /activity?activity-type=posts
        """
        header = request.headers.get("Authorization")

        activity_type = request.args.get("activity-type")



        if header is None: 
            return {"message": "Please Login"}, 404


        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)  # {'id':실제 id} 딕셔너리형태로 돌려줌
        activity_info = mongodb.find_one(query={"id": token_decoded["id"]}, collection_name="user", projection_key={'_id': 0, "activity":1})
        # activity_info를 통해서 공감, 스크랩, 댓글, 게시글 별 content_id와 board_type을 얻을 수 있음
        # 이거 가지고 프론트가 get을 요청하거나 백에서 그거 까지 해서 주거나

        # activity = activity_info[activity_type]  # 리스트로 이루어진 리스트  "like" : [("content_id", "board_type"), ("content_id", "board_type")]

        activity =  activity_info["activity"][activity_type]
        # return activity

        post_list = []
        for post in activity:
            # post_list.append(post[0])
            # post_list.append(post[1])
            board_type = post[0]+"_board"
            content_id = post[1]
            result = mongodb.find_one(query={"_id": ObjectId(content_id)},collection_name=board_type)
            # result["_id"] = str(result["_id"])
            result["_id"] = str(result["_id"])
            post_list.append(result)

        if not post_list:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500
        else:
            return {
                "post_list" : post_list
            }