from re import X, sub
from flask import request
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from pymongo.message import update

import mongo

import dateutil.parser

mongodb = mongo.MongoHelper()

Post = Namespace("post", description="게시물 관련 API")
Reply = Namespace("reply", description="댓글 관련 API")
SubReply = Namespace("subreply", description="대댓글 관련 API")


# 게시글 변수 설정 함수
def get_post_variables(post_info):
    post_id = post_info["_id"]
    board_type = post_info["boardType"] + "_board"
    author = post_info["author"]["_id"]
    
    return post_id, board_type, author


# JSON 형태로 response하기 위해 string 타입으로 변환하는 함수
def convert_to_string(post, *args):
    for key in args:
        post[key] = str(post[key])


# author 정보 embed, 활동 정보 link
class make_reference():
    def __init__(self, board_type, author):
        self.board_type = board_type
        self.author = author
    

    # author 정보 embed
    def embed_author_information_in_object(self):
            embeded_author_info ={}

            total_author_info = mongodb.find_one(query={"_id":self.author}, collection_name="user")

            needed_author_info = ["_id", "subInformation.nickname", "information.type", "subInformation.profileImage"]

            for info in needed_author_info:
                if "." in info:
                    field, key = info.split(".")
                    embeded_author_info[key] = total_author_info[field][key]
                else:
                    embeded_author_info[info] = total_author_info[info]
            
            return embeded_author_info


    # 활동 정보 link
    def link_activity_information_in_user(self, operator, field, post_id, reply_id=None, user=None):
        if reply_id:
            board_type = self.board_type.replace("_board_reply", "")
        else:
            board_type = self.board_type.replace("_board","")
        
        if user:
            user = user
        else:
            user = self.author

        # 회원탈퇴 시 댓글, 대댓글의 author을 None으로 바꾸려면 reply_id 필요함
        new_activity_info = [board_type, str(post_id), str(reply_id)]

        result = mongodb.update_one(query={"_id": user}, collection_name="user", modify={operator: {field: new_activity_info}})

        return result


# 수정, 삭제 시 작성자 확인
def ownership_required(func):  
    def wrapper(self):
        json_info = request.get_json()
        if not("user" in json_info):
            return {"queryStatus": "user의 정보가 필요합니다"}
        elif not("author" in json_info):
            print("게시글 integer 수정하는 경우 author 없음")
            result = func(self)
            return result
        else:
            print("게시글 string 수정, 게시글 삭제하는 경우")
            author = json_info["author"]["_id"]
            user = json_info["user"]
            if author == user:
                result = func(self)
                return result
            else:
                return {"queryStatus": "작성자가 아닙니다"}
    return wrapper


# 게시글 관련 API
@Post.route("")
class PostControl(Resource):
    def get(self):  # 게시글 조회
        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board"

        # viewCount +1
        update_status = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                           collection_name=board_type,
                                           modify={"$inc": {"views": 1}})

        # 게시글 조회
        post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                  collection_name=board_type)
        
    
        if not post:
            return {"queryStatus": "not found"}, 500

        elif update_status.raw_result["n"] == 0:
            return {"queryStatus": "views update fail"}, 500

        else:
            convert_to_string(post, "_id", "date")
            return post


    @ownership_required
    def delete(self):  # 게시글 삭제
        """특정 id의 게시글을 삭제합니다."""
        post_info = request.get_json()
        post_id, board_type, author = get_post_variables(post_info)

        # 게시글 삭제
        result = mongodb.delete_one(query={"_id": ObjectId(post_id)}, collection_name=board_type)

        # 회원활동정보 삭제
        making_reference = make_reference(board_type=board_type, author=author)
        activity_result = making_reference.link_activity_information_in_user(field="activity.posts", post_id=post_id, operator="$pull")


        if result.raw_result["n"] == 0 :
            return {"queryStatus": "post delete fail"}
        elif activity_result.raw_result["n"] == 0:
            return {"queryStatus": "delete activity fail"}
        else:
            return {"queryStatus": "success"}, 500


    def post(self):  # 게시글 생성
        """게시글을 생성합니다."""
        try:
            post_info = request.get_json()
            post_id, board_type, author = get_post_variables(post_info)
            
            del post_info["_id"]
            post_info["date"] = dateutil.parser.parse(post_info["date"])
            
           
            # 회원정보 embeded 형태로 return
            making_reference = make_reference(board_type=board_type, author=author)
            author = making_reference.embed_author_information_in_object()
            post_info["author"] = author

            # 게시글 등록
            post_id = mongodb.insert_one(data=post_info, collection_name=board_type)

            # 회원활동 정보 등록
            result = making_reference.link_activity_information_in_user(field="activity.posts", post_id=post_id, operator="$addToSet")
            
            # 등록완료된 게시글 조회
            if result.raw_result["n"] == 0:
                return {"queryStatus": "update activity fail"}
            else:
                post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                    collection_name=board_type)
                convert_to_string(post, "_id", "date")

                return post

        except TypeError as t:
            return {
                "TypeError": str(t)
            }
        except AttributeError as a:
            return {
                "AttributeError": str(a)
            }
        except IndexError as i:
            return {
                "IndexError": str(i)
            } 
        except dateutil.parser.ParserError as p:
            return {
                "DatetimeError": str(p)
            } 


    @ownership_required
    def put(self):  # 게시글 수정
        """특정 id의 게시글을 수정합니다."""

        post_info = request.get_json()
        if ("author" in post_info): # string을 수정하는 경우
            print("String 수정하는 경우")
            post_id, board_type, author = get_post_variables(post_info)
            article_key = ["title", "content", "image"]

            modified_article = {}
            for key in article_key:
                modified_article[key] = post_info[key]
            
            # 게시글 정보 업데이트
            result = mongodb.update_one(query={"_id": ObjectId(post_id)},
                                    collection_name=board_type,
                                    modify={"$set": modified_article})
            

        else: # integer을 수정하는 경우
            print("integer 수정하는 경우")
            post_id = post_info["_id"]
            board_type = post_info["boardType"]+"_board"
            user = post_info["user"]
            activity = post_info["activity"]

            past_user_list = mongodb.find_one(query={"_id":ObjectId(post_id)}, collection_name=board_type, projection_key={"_id":False, activity:True})[activity]
            print(past_user_list)
            

            if user in past_user_list:
                if activity == "likes":
                    return{"queryStatus": "already like"}
                else:
                    operator="$pull"
                    result = mongodb.update_one(query={"_id":ObjectId(post_id)}, collection_name=board_type, modify={operator:{activity:user}})

            else:
                if activity =="likes":
                    past_likes = len(mongodb.find_one(query={"_id": ObjectId(post_id)}, collection_name=board_type, projection_key={"_id":False, "likes":True})["likes"])
                    print("past_likes : ", past_likes)

                past_user_list.append(user)
                print(past_user_list)

                operator = "$addToSet"
                result = mongodb.update_one(query={"_id":ObjectId(post_id)}, collection_name=board_type, modify={operator:{activity:user}})

                if activity =="likes":
                    # 인기게시판 관련
                    modified_post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                            collection_name=board_type)
                    if (past_likes < 10) and (len(modified_post["likes"]) == 10) :
                        print("여기 좋아요 10 넘음")
                        hot_post_info={}
                        
                        # hot_board 컬렉션에 저장할 key 값
                        hot_board_element = ["_id", "boardType", "date"]
            
                        for key in hot_board_element:
                            hot_post_info[key] = modified_post[key]
                        print(hot_post_info)
                        
                        mongodb.insert_one(data=hot_post_info, collection_name="hot_board")

            # 활동 업데이트
            making_reference = make_reference(board_type=board_type, author=None)
            field = "activity." + activity
            
            activity_result = making_reference.link_activity_information_in_user(field=field, post_id=post_id, operator=operator, user=user)
            if activity_result.raw_result["n"] == 0:
                return {"queryStatus": "user activity update fail"}

            
            
            


        if result.raw_result["n"] == 0:  # 게시글 정보(string, likes, reports, bookmarks) 업데이트 실패한 경우
            return {"queryStatus": "post update fail"}
        else:
            modified_post = mongodb.find_one(query={"_id": ObjectId(post_id)},
                                            collection_name=board_type)

            convert_to_string(modified_post, "_id", "date")
            return modified_post


# 댓글 조회 함수
def get_reply_list(post_id=None, board_type=None):
    cursor = mongodb.find(query={"postId": post_id},
                                collection_name=board_type)  # 댓글은 오름차순

    reply_list = []
    for reply in cursor:
        reply["_id"] = str(reply["_id"])
        reply_list.append(reply)
    
    return reply_list


# 댓글 관련 API
@Reply.route("")
class CommentControl(Resource):
    """ 댓글생성, 삭제, 조회(대댓글 포함) """

    def post(self):  # 댓글 작성
        """댓글을 생성합니다."""
        reply_info = request.get_json()
        del reply_info["_id"]

        board_type = reply_info["boardType"] + "_board_reply"
        post_id = reply_info["postId"]
        author = reply_info["author"]["_id"]

        
        making_reference = make_reference(board_type=board_type, author=author)

        # 회원정보 embeded 형태로 등록
        author = making_reference.embed_author_information_in_object()
        reply_info["author"] = author

        # 댓글 db에 저장
        reply_id = mongodb.insert_one(data=reply_info, collection_name=board_type)
        print(reply_id)
        
        print(post_id)
        # 회원활동 정보 link 형태로 등록
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=reply_id, operator="$addToSet")


        # 댓글 조회
        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        
        return {
            "replyList": reply_list
        }


    def get(self):  # 댓글 조회
        """댓글을 조회합니다."""

        post_id = request.args.get("postId")
        board_type = request.args.get("boardType") + "_board_reply"
        
        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        return {
            "replyList": reply_list
        }


    def put(self):  # 좋아요
        """좋아요를 저장합니다"""
        reply_info = request.get_json()
        reply_id = reply_info["_id"]
        board_type = reply_info["boardType"]+"_board_reply"
        user = reply_info["user"]

        past_likes_list = mongodb.find_one(query={"_id":ObjectId(reply_id)}, collection_name=board_type, projection_key={"_id":False, "likes":True})["likes"]
       
        if user in past_likes_list:
            return{"queryStatus": "already like"}
        else:
            update_status = mongodb.update_one(query={"_id": ObjectId(reply_id)}, collection_name=board_type, modify={"$addToSet": {"likes": user}})
        
        if update_status.raw_result["n"]==0:
            return{"queryStatus": "likes update fail"}
        else:
            return{"queryStatus": "likes update success"}


    @ownership_required
    def delete(self):  # 댓글 삭제
        """댓글을 삭제합니다."""
        reply_info = request.get_json()

        board_type = reply_info["boardType"] + "_board_reply"
        post_id = reply_info["postId"]
        reply_id = reply_info["_id"]
        author = reply_info["author"]["_id"]
        whether_subreply = mongodb.find_one(query={"parentReplyId": reply_id}, collection_name=board_type)


        if not whether_subreply:  # 대댓글이 없는 경우
            result = mongodb.delete_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=board_type)
        else:  # 대댓글이 있는 경우
            alert_delete = {
                "author":{},
                "content": None,
                "date": None,
                "likes": None
            }
            result = mongodb.update_one(query={"_id": ObjectId(reply_id)},
                                        collection_name=board_type,
                                        modify={"$set": alert_delete})
        
        # 댓글 조회
        reply_list = get_reply_list(post_id=post_id, board_type=board_type)

        making_reference = make_reference(board_type=board_type, author=author)

        # 회원활동정보 삭제
        making_reference.link_activity_information_in_user(field="activity.replies", post_id=post_id, reply_id=reply_id, operator="$pull")

        if result.raw_result["n"] == 1:
            return {
            "replyList": reply_list
        }
        else:
            return {"queryStatus": "reply delete failed"}, 500
