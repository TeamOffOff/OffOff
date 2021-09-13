from logging import DEBUG
from flask import Flask
from flask_socketio import SocketIO
from flask_restx import Api
from flask_jwt_extended import JWTManager

from .utils import APP_SECRET_KEY, JWT_SECRET_KEY

from .list import BoardList, PostList, UserControl
from .post import Post, Reply, Chat
from .user import Activity, User, Token

print("api_helper __init__.py진입")

socketio = SocketIO(logger=True, engineio_logger=True)


def create_app(debug=False):
    """create an application."""
    print("create_app 실행")

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