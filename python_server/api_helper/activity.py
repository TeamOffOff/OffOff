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
    def put(self):  # 활동 추가
        """
        사용자 활동 추가하기
        """
        header = request.headers.get("Authorization")  # 이 회원의 활동정보 변경

        if header is None: 
            return {"message": "Please Login"}, 404

        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)

        new_activity_info = request.get_json()  
        """
        {
            "likes" : ["board_type", "content_id"]
        } 
        """

        user_activity = mongodb.find_one(query={"id": token_decoded["id"]}, collection_name="user", projection_key={'_id': 0, "activity": 1})
        """
        {
         "activity" : {
           "likes" : [["board_type", "content_id"], ["board_type", "content_id"]],
           "posts" : [[], []]
        }
        """

        for key in new_activity_info:
            specific_activity = user_activity["activity"][key]
            specific_activity.append(new_activity_info[key])  # insert : 제일 앞으로 추가함
        
        result = mongodb.update_one(query={"id": token_decoded["id"]}, collection_name="user", modify={"$set" : user_activity})

        if result.raw_result["n"] == 1:
            return {"query_status": "활동을 저장했습니다"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500
    

    def delete(self):  # 활동 제거(활동 취소 시, 게시글 삭제 시)
        """
        사용자 활동 지우기
        """
        header = request.headers.get("Authorization")  # 이 회원의 활동정보 변경

        if header is None: 
            return {"message": "Please Login"}, 404

        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)

        new_activity_info = request.get_json()  
        """
        {
            "like" : ["board_type", "content_id"]
        } 
        """
        
        user_activity = mongodb.find_one(query={"id": token_decoded["id"]}, collection_name="user", projection_key={'_id': 0, "activity": 1})
        """
        {
         "activity" : {
           "likes" : [["board_type", "content_id"], ["board_type", "content_id"]],
           "posts" : [[], []]
        }
        """

        for key in new_activity_info:  # key : "likes" ,"posts"
            content_id = new_activity_info[key][1]
            specific_activity = user_activity["activity"][key]  # "likes"의 구체적인 내용 : 리스트로 이루어진 리스트
            for post in specific_activity:  # post는 개별 게시글
                if content_id in post:
                    specific_activity.remove(post)

        result = mongodb.update_one(query={"id": token_decoded["id"]}, collection_name="user", modify={"$set" : user_activity})

        if result.raw_result["ok"] == 1:
            return {"query_status": "활동을 제거했습니다"}
        else:
            return {"query_status": "해당 id의 게시글을 찾을 수 없습니다."}, 500


    def get(self):  # 회원활동 탭에서 보여지는 정보 (게시글 리스트)
        """
        사용자 활동과 관련된 게시글 보여주기
        /activity?activity-type=likes
        /activity?activity-type=posts
        """
        header = request.headers.get("Authorization")

        if header is None: 
            return {"message": "Please Login"}, 404

        token_decoded = jwt.decode(header, SECRET_KEY, ALGORITHM)  # {'id':실제 id} 딕셔너리형태로 돌려줌

        activity_type = request.args.get("activity-type")       

        activity_info = mongodb.find_one(query={"id": token_decoded["id"]}, collection_name="user", projection_key={'_id': 0, "activity":1})
        # activity_info를 통해서 공감, 스크랩, 댓글, 게시글 별 content_id와 board_type을 얻을 수 있음
        # 이거 가지고 프론트가 get을 요청하거나 백에서 그거 까지 해서 주거나

        specific_activity =  activity_info["activity"][activity_type]
        # 리스트로 이루어진 리스트  "like" : [["board_type", "content_id"], ["board_type", "content_id"]

        post_list = []
        for post in specific_activity:
            try :
                board_type = post[0]+"_board"
                content_id = post[1]

                result = mongodb.find_one(query={"_id": ObjectId(content_id)},collection_name=board_type)
                result["_id"] = str(result["_id"])

                post_list.append(result)  # 제일 뒤로 추가함 => 결국 위치 동일

                post_list.sort(key=lambda x:x["_id"], reverse=True )
            
            except TypeError:
                pass
        
        return {
            "post_list" : post_list
        }