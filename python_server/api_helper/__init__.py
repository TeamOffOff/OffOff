from logging import DEBUG
from flask import Flask
from flask_socketio import SocketIO
from flask_restx import Api
from flask_jwt_extended import JWTManager

from api_helper.utils import APP_SECRET_KEY, JWT_SECRET_KEY

from api_helper.board import BoardList, PostList, UserControl
from api_helper.post import Post, Reply, Chat
from api_helper.user import Activity, User, Token
from api_helper.chat import ChatNamepsace


socketio = SocketIO(logger=True, engineio_logger=True)

def create_app(debug=False):
    """create an application."""

    app = Flask(__name__)

    app.config.update(
        DEBUG=debug,
        SECRET_KEY = APP_SECRET_KEY,
        JWT_SECRET_KEY = JWT_SECRET_KEY
)

    # flask_jwt_extended
    jwt = JWTManager(app)

    # socketio
    socketio.init_app(app)

    # flask_restx
    api = Api(app)


    socketio.on_namespace(ChatNamepsace('/chat'))

    api.add_namespace(Chat, "/chat")

    api.add_namespace(BoardList, "/boardlist")
    api.add_namespace(PostList, "/postlist")
    api.add_namespace(UserControl, "/userlist")

    api.add_namespace(Post, "/post")
    api.add_namespace(Reply, "/reply")

    api.add_namespace(User, "/user")
    api.add_namespace(Token, '/refresh')
    api.add_namespace(Activity, "/activity")

    return app

