from flask import Flask
from flask_restx import Api

from flask_jwt_extended import JWTManager

from api_helper.utils import APP_SECRET_KEY, JWT_SECRET_KEY

from api_helper.list import BoardList, PostList, UserControl, MessageList, SearchList
from api_helper.post import Post
from api_helper.reply import Reply, SubReply
from api_helper.user import Activity, User, Token
from api_helper.message import Message
from api_helper.calendar import Calendar, Shift, SavedShift

import mongo as mongo

# import logging


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
api.add_namespace(SubReply, "/subreply")

api.add_namespace(User, "/user")
api.add_namespace(Token, '/refresh')
api.add_namespace(Activity, "/activity")

api.add_namespace(Message, "/message")
api.add_namespace(MessageList, "/messagelist")

api.add_namespace(Calendar, "/calendar")
api.add_namespace(Shift, '/shift')
api.add_namespace(SavedShift, '/savedshift')

# if not app.debug :
#         # 여기 지금 작동 안 함 ㅠㅠ
#         # logging
#         logger = logging.getLogger(__name__)
#         logger.setLevel(logging.DEBUG)

#         formatter = logging.Formatter(fmt='%(asctime)s:%(module)s:%(levelname)s:%(message)s', datefmt='%Y-%m-%d %H:%M:%S')

#         # INFO 레벨 이상의 로그를 콘솔에 출하는 Handler
#         console_handler = logging.StreamHandler()
#         console_handler.setLevel(logging.INFO)
#         console_handler.setFormatter(formatter)
#         logger.addHandler(console_handler)

#         # DEBUG 레벨 이상의 로그를 'debug.log'에 출력하는 Handler
#         file_debug_handler = logging.FileHandler('debug.log')
#         file_debug_handler.setLevel(logging.DEBUG)
#         file_debug_handler.setFormatter(formatter)
#         logger.addHandler(file_debug_handler)

#         # ERROR 레벨 이상의 로그를 'error.log'에 출력하는 Handler
#         file_error_handler = logging.FileHandler('error.log')
#         file_error_handler.setLevel(logging.ERROR)
#         file_error_handler.setFormatter(formatter)
#         logger.addHandler(file_error_handler)   


if __name__ == "__main__":
    print("__name__ == __main__")
    mongodb = mongo.MongoHelper()
    app.run(host="0.0.0.0", port="5000")
