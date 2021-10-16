from logging import DEBUG
from flask import Flask
from flask_restx import Api
from flask_jwt_extended import JWTManager

from api_helper.utils import APP_SECRET_KEY, JWT_SECRET_KEY

from api_helper.list import BoardList, PostList, UserControl, MessageList, SearchList
from api_helper.post import Post, Reply
from api_helper.user import Activity, User, Token
from api_helper.message import Message
from api_helper.calendar import Calendar, Shift, SavedShift

import mongo as mongo

app = Flask(__name__)

app.config.update(
        DEBUG=True,
        SECRET_KEY = APP_SECRET_KEY,
        JWT_SECRET_KEY = JWT_SECRET_KEY
)

# flask_jwt_extended
jwt = JWTManager(app)


# flask_restx
api = Api(app)

api.add_namespace(BoardList, "/boardlist")
api.add_namespace(PostList, "/postlist")
api.add_namespace(UserControl, "/usercontrol")

api.add_namespace(SearchList, "/searchlist")

api.add_namespace(Post, "/post")
api.add_namespace(Reply, "/reply")

api.add_namespace(User, "/user")
api.add_namespace(Token, '/refresh')
api.add_namespace(Activity, "/activity")

api.add_namespace(Message, "/message")
api.add_namespace(MessageList, "/messagelist")

api.add_namespace(Calendar, "/calendar")
api.add_namespace(Shift, '/shift')
api.add_namespace(SavedShift, '/savedshift')


if __name__ == "__main__":
    print("__name__ == __main__")
    mongodb = mongo.MongoHelper()
    app.run(host="0.0.0.0", port="5000")
