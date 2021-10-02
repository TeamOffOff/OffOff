import mongo as mongo

mongodb = mongo.MongoHelper()

"""author 정보 embed, 활동 정보 link 클래스"""


class MakeReference:
    def __init__(self, board_type, user):
        self.board_type = board_type
        self.user = user

    # author 정보 embed
    def embed_author_information_in_object(self):

        embedded_author_info = {}

        total_author_info = mongodb.find_one(query={"_id": self.user}, collection_name="user")

        needed_author_info = ["_id", "subInformation.nickname", "information.type", "subInformation.profileImage"]

        for info in needed_author_info:
            if "." in info:
                field, key = info.split(".")
                embedded_author_info[key] = total_author_info[field][key]
            else:
                embedded_author_info[info] = total_author_info[info]

        return embedded_author_info

    # 활동 정보 link
    def link_activity_information_in_user(self, operator, field, post_id, reply_id=None):
        if reply_id:
            board_type = self.board_type.replace("_board_reply", "")
        else:
            board_type = self.board_type.replace("_board", "")

        # 회원탈퇴 시 댓글, 대댓글의 author을 None으로 바꾸려면 reply_id 필요함
        new_activity_info = {
            "boardType": board_type, 
            "postId": str(post_id), 
            "replyId": str(reply_id)
            }

        result = mongodb.update_one(query={"_id": self.user}, collection_name="user", modify={operator: {field: new_activity_info}})

        return result