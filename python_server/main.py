from flask import Flask
from flask_restx import Api

import mongo
from api_helper.board import BoardList, PostList, UserList
from api_helper.post import Post, Reply, SubReply
from api_helper.user import User, Activity

app = Flask(__name__)
api = Api(app)

api.add_namespace(BoardList, "/boardlist")
api.add_namespace(PostList, "/postlist")
api.add_namespace(UserList, "/userlist")

api.add_namespace(Post, "/post")
api.add_namespace(Reply, "/reply")
api.add_namespace(SubReply, "/subreply")

api.add_namespace(User, "/user")
api.add_namespace(Activity, "/activity")



if __name__ == "__main__":
    mongodb = mongo.MongoHelper()
    app.run(debug=True, host="0.0.0.0", port=5000)
