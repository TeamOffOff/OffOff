from datetime import datetime
from flask import request, make_response
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from werkzeug.wrappers import Response
from flask_jwt_extended import jwt_required

from controller.image import *
from controller.reference import *
from controller.filter import check_jwt, ownership_required
from controller.etc import get_variables, get_reply_list
import mongo as mongo

mongodb = mongo.MongoHelper()

Reply = Namespace("reply", description="댓글 관련 API")
SubReply = Namespace('subreply', description="대댓글 관련 API")
"""
댓글 관련 API
"""

# 댓글 관련 API
@Reply.route("")
class ReplyControl(Resource):
    """ 댓글생성, 삭제, 좋아요, 조회"""
    @jwt_required()
    def post(self):  # 댓글 작성
        """댓글을 생성합니다."""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        # 클라이언트에서 받은 변수 가져오기
        request_info = request.get_json()
        post_id = request_info["postId"]
        board_type = request_info["boardType"]
        del request_info["_id"]

        print(board_type)
        
        # reply 컬랙션 이름으로
        reply_board_type = board_type + "_board_reply"
        print(reply_board_type)

        # date 추가
        request_info["date"] = datetime.now()

        # 회원정보 embedded 형태로 등록
        making_reference = MakeReference(board_type=reply_board_type, user=user_id)
        author = making_reference.embed_author_information_in_object()
        request_info["author"] = author

        # likes 추가
        request_info["likes"] = []

        # childrenReplies 추가
        request_info["childrenReplies"] = []

        # 댓글 db에 저장
        reply_id = mongodb.insert_one(data=request_info, collection_name=reply_board_type)

        # 회원활동 정보 link 형태로 등록
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=reply_id, operator="$addToSet")

        # post 컬랙션 이름으로
        post_board_type = board_type + "_board"
        print(post_board_type)

        # 댓글 수 +1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=post_board_type, modify={"$inc": {"replyCount": 1}})
        print(update_status)

        if update_status.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "replyCount update fail"}, 500)

        else:
            # 댓글 조회
            reply_list = get_reply_list(post_id=post_id, board_type=reply_board_type)
            response_result = make_response({"replyList": reply_list}, 200)

        return response_result

    @jwt_required()
    def get(self):  # 댓글 조회
        """댓글을 조회합니다."""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board_reply"

        reply_list = get_reply_list(post_id=post_id, board_type=board_type)
        
        response_result = make_response({"replyList": reply_list}, 200)

        return response_result

    @jwt_required()
    def put(self):  # 좋아요
        """좋아요를 저장합니다"""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        # 클라이언트에서 받은 변수 가져오기
        request_info, reply_id, board_type, user = get_variables()
        if not user:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        # db 컬랙션 명으로 변경
        board_type = board_type + "_board_reply"

        reply = mongodb.find_one(query={"_id":ObjectId(reply_id)}, collection_name=board_type)
        
        reply_past_likes_list = reply["likes"]

        if user in reply_past_likes_list:  # 이미 좋아요 한 경우
            response_result = make_response({"queryStatus": "already like"}, 201)
            return response_result

        update_status = mongodb.update_one(query={"_id": ObjectId(reply_id)}, collection_name=board_type, modify={"$addToSet": {"likes": user}})

        if update_status.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "likes update fail"}, 500)
        else:
            modified_reply = mongodb.find_one(query={"_id":ObjectId(reply_id)}, collection_name=board_type)
            modified_reply["_id"] = str(modified_reply["_id"])
            modified_reply["date"] = (modified_reply["date"]).strftime("%Y년 %m월 %d일 %H시 %M분")

            # 비밀게시판인 경우에 댓글 author 을 None으로 변경
            if board_type == "secret_board_reply":
                modified_reply["author"] = None

            # 댓글에 있는 author의 profileImage가 있는 경우 base64로 인코딩
            if modified_reply["author"]: #secret인 경우 None임
                if modified_reply["author"]["_id"]: #탈퇴한 경우 _id가 None임
                    if modified_reply["author"]["profileImage"]: #secret도 아니고 탈퇴한 경우도 아닌데, profileImage가 있는 경우
                        modified_reply["author"]["profileImage"] = get_image(reply["author"]["profileImage"], "user", "200")
            
            if modified_reply["childrenReplies"]:  # 대댓글이 있으면
                for children_reply in modified_reply["childrenReplies"]: # 대댓글 하나씩 돌면서 author profileImage 인코딩
                    
                    # 비밀게시판인 경우에 대댓글 author 을 None으로 변경
                    if board_type == "secret_board_reply":
                        children_reply["author"] = None

                    # 대댓글에 있는 author의 profileImage가 있는 경우 base64로 인코딩
                    if children_reply["author"]: #secret인 경우 None임
                        if children_reply["author"]["_id"]: #탈퇴한 경우 _id가 None임
                            if children_reply["author"]["profileImage"]: #secret도 아니고 탈퇴한 경우도 아닌데, profileImage가 있는 경우
                                children_reply["author"]["profileImage"] = get_image(children_reply["author"]["profileImage"], "user", "200")
                                
            response_result = make_response(modified_reply, 200)
        
        return response_result


    @ownership_required
    def delete(self):  # 댓글 삭제
        """댓글을 삭제합니다."""
        # 클라이언트에서 받은 변수 가져오기
        request_info, reply_id, board_type, user = get_variables()
        post_id = request_info["postId"]
        print(board_type)

        # reply 컬랙션 이름으로
        reply_board_type = board_type + "_board_reply"
        print(reply_board_type)

        whether_subreply = request_info["isChildReply"]
        print(whether_subreply)
        # 있으면 Ture, 없으면 False
    
        if not whether_subreply:  # 대댓글이 없는 경우
            result = mongodb.delete_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=reply_board_type)
        else:  # 대댓글이 있는 경우
            alert_delete = {
                "author": None,  # 대댓글이 있는데 삭제된 경우 그냥 author = null이 될 수 있게
                "content": None,
                "date": None,
                "likes": None
            }
            result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=reply_board_type,
                                        modify={"$set": alert_delete})
        if result.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "reply delete failed"}, 500)
            return response_result

        # 회원활동정보 삭제
        making_reference = MakeReference(board_type=reply_board_type, user=user)
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=reply_id, operator="$pull")

        # post 컬랙션 이름으로
        post_board_type = board_type + "_board"
        print(post_board_type)

        # 댓글 -1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=post_board_type, modify={"$inc": {"replyCount": -1}})

        if update_status.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "replyCount update fail"}, 500)
    
        else: 
            # 댓글 조회
            reply_list = get_reply_list(post_id=post_id, board_type=reply_board_type)
            response_result = make_response({"replyList": reply_list}, 200)
        
        return response_result


@SubReply.route("")
class SubReplyControl(Resource):
    """대댓글 생성, 삭제, 좋아요"""
    @jwt_required()
    def post(self):  # 대댓글 작성
        """대댓글을 생성합니다"""
        user_id = check_jwt()
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        # 클라이언트에서 받은 변수 가져오기
        request_info = request.get_json()
        post_id = request_info["postId"]
        board_type = request_info["boardType"]
        parent_reply_id = request_info["parentReplyId"]
        print(board_type)

        # reply 컬랙션 이름으로
        reply_board_type = board_type + "_board_reply"
        print(reply_board_type)

        # date 추가
        request_info["date"] = datetime.now()
        request_info["date"] = request_info["date"].strftime("%Y년 %m월 %d일 %H시 %M분")

        # 회원정보 embedded 형태로 등록
        making_reference = MakeReference(board_type=reply_board_type, user=user_id)
        author = making_reference.embed_author_information_in_object()
        request_info["author"] = author

        # likes 추가
        request_info["likes"] = []

        # 댓글 등록
        result = mongodb.update_one(query={"_id":ObjectId(parent_reply_id)}, collection_name=reply_board_type, modify={"$addToSet":{"childrenReplies":request_info}})
        
        if result.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "subreply update fail"}, 500)
            return response_result

        # 회원활동 정보 link 형태로 등록
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=parent_reply_id, operator="$addToSet")

        # post 컬랙션 이름으로
        post_board_type = board_type + "_board"
        print(post_board_type)

        # 댓글 수 +1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=post_board_type, modify={"$inc": {"replyCount": 1}})
        print(update_status)

        if update_status.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "replyCount update fail"}, 500)

        else:
            # 댓글 조회
            reply_list = get_reply_list(post_id=post_id, board_type=reply_board_type)
            response_result = make_response({"replyList": reply_list}, 200)
        
        return response_result


    @ownership_required
    def delete(self):  # 대댓글 삭제
        """대댓글 삭제"""
        # 클라이언트에서 받은 변수 가져오기
        request_info = request.get_json()
        post_id = request_info["postId"]
        board_type = request_info["boardType"]
        parent_reply_id = request_info["parentReplyId"]
        print(board_type)

        user_id = check_jwt()

        # reply 컬랙션 이름으로
        reply_board_type = board_type + "_board_reply"
        print(reply_board_type)

        # 삭제
        subreply_id = request_info["_id"]
        print(subreply_id)
        # $elemMatch 없어야 삭제됨
        result = mongodb.update_one(query={"_id": ObjectId(parent_reply_id)}, collection_name=reply_board_type, modify={"$pull":{"childrenReplies":{"_id":subreply_id}}})

        if result.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "subrely delete fail"}, 500)
            return response_result

        # 회원활동정보 삭제
        making_reference = MakeReference(board_type=reply_board_type, user=user_id)
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=parent_reply_id, operator="$pull")

        # post 컬랙션 이름으로
        post_board_type = board_type + "_board"
        print(post_board_type)

        # 댓글 -1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)}, collection_name=post_board_type, modify={"$inc": {"replyCount": -1}})

        if update_status.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "replyCount update fail"}, 500)

        else:
            # 댓글 조회
            reply_list = get_reply_list(post_id=post_id, board_type=reply_board_type)
            response_result = make_response({"replyList": reply_list}, 200)
    
        return response_result
    

    @jwt_required()
    def put(self):
        """좋아요를 저장합니다"""
        user_id = check_jwt()  # user_id가 있는지, blocklist는 아닌지
        if not user_id:
            response_result = make_response({"queryStatus": "wrong Token"}, 403)
            return response_result

        # 클라이언트에서 받은 변수 가져오기
        request_info = request.get_json()
        subreply_id = request_info["_id"]
        parent_reply_id = request_info["_id"].split("_")[0]
        board_type = request_info["boardType"]

        print(parent_reply_id, subreply_id)

        # db 댓글컬랙션 명으로 변경
        board_type = board_type + "_board_reply"

        # 해당 댓글 찾기
        reply = mongodb.find_one(query={"_id":ObjectId(parent_reply_id)}, collection_name=board_type)
        
        # 해당 댓글의 대댓글 리스트
        children_replies = reply["childrenReplies"]

        # 해당 subreply 찾기
        for subreply in children_replies:
            if subreply["_id"] == subreply_id:
                subreply_past_likes_list = subreply["likes"]
                
                # 이미 좋아요를 누른 경우
                if user_id in subreply_past_likes_list:
                    response_result = make_response({"queryStatus": "already like"}, 201)
                    return response_result

        print(user_id)
        update_status = mongodb.update_one(query={"_id": ObjectId(parent_reply_id)}, collection_name=board_type, modify={"$addToSet": {"childrenReplies.$[elem].likes": user_id}}, array_filters=[{"elem._id":subreply_id}])

        # 좋아요한 사용자 리스트 업데이트 오류 발생
        if update_status.raw_result["n"] == 0:
            response_result = make_response({"queryStatus": "likes update fail"}, 500)
            return response_result

        modified_reply = mongodb.find_one(query={"_id":ObjectId(parent_reply_id)}, collection_name=board_type)
        children_replies = modified_reply["childrenReplies"]

        # 해당 subreply만 찾아서 보내기
        for subreply in children_replies:
            if subreply["_id"] == subreply_id:
                if board_type == "secret_board_reply":
                    subreply["author"] = None
                
                if subreply["author"]: # secret board가 아님
                    if subreply["author"]["_id"]:
                        if subreply["author"]["profileImage"]:
                            subreply["author"]["profileImage"] = get_image(subreply["author"]["profileImage"], "user", "200")
            
                response_result = make_response(subreply, 200)
                return response_result


## 만약에 addtoset해서 달라진 게 없으면 좋아요 했떤 거라고 하면되나? 그런데 그러면 오류 발생을 못잡아낼 수도 있는디
## subreplies 들은 datetime을 문자열로 바꿔서 저장하는데,,,,,,댓글은 어떻게할지 다시 고민해보기
## 댓글 대댓글 author이랑 user랑 일치하는지 확인하기 !!!!
