from re import DEBUG
from flask import Flask
from flask_restx import Api
from flask_jwt_extended import JWTManager
from flask_socketio import SocketIO
import mongo

from api_helper.board import BoardList, PostList, UserControl
from api_helper.post import Post, Reply
from api_helper.user import Activity, User, Token
from api_helper.utils import SECRET_KEY
from api_helper.chat import ChatNamepsace



app = Flask(__name__)


# flask_restx
api = Api(app)


# flask_jwt_extended
jwt = JWTManager(app)


# flask_socketio
socketio = SocketIO(logger=True, engineio_logger =True)
socketio.init_app(app)


# config
app.config.update(
    DEBUG= True,
    JWT_SECRET_KEY = SECRET_KEY
)


# http 통신 namespace 등록
api.add_namespace(BoardList, "/boardlist")
api.add_namespace(PostList, "/postlist")
api.add_namespace(UserControl, "/userlist")

api.add_namespace(Post, "/post")
api.add_namespace(Reply, "/reply")

api.add_namespace(User, "/user")
api.add_namespace(Token, '/refresh')
api.add_namespace(Activity, "/activity")


# 소켓 통신 namespace 등록
socketio.on_namespace(ChatNamepsace('/chat'))


if __name__ == "__main__":
    mongodb = mongo.MongoHelper()
    app.run(debug=True, host="0.0.0.0", port=5000)
