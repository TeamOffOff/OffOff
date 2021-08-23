from re import DEBUG
from flask import Flask
from flask_restx import Api
from flask_jwt_extended import JWTManager
import mongo

from api_helper.board import BoardList, PostList, UserList
from api_helper.post import Post, Reply
from api_helper.user import Activity, User
from api_helper.utils import SECRET_KEY

app = Flask(__name__)

api = Api(app)

jwt = JWTManager(app)

app.config.update(
    DEBUG= True,
    JWT_SECRET_KEY = SECRET_KEY
)

api.add_namespace(BoardList, "/boardlist")
api.add_namespace(PostList, "/postlist")
api.add_namespace(UserList, "/userlist")

api.add_namespace(Post, "/post")
api.add_namespace(Reply, "/reply")

api.add_namespace(User, "/user")
api.add_namespace(Activity, "/activity")


if __name__ == "__main__":
    mongodb = mongo.MongoHelper()
    app.run(debug=True, host="0.0.0.0", port=5000)
