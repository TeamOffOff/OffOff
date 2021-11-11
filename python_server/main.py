from flask import Flask
from flask_restx import Api
from controller.logger import get_logger
import os


from flask_jwt_extended import JWTManager

from api_helper.utils import APP_SECRET_KEY, JWT_SECRET_KEY

from api_helper.list import BoardList, PostList, UserControl, MessageList, SearchList, TotalSearchList
from api_helper.post import Post
from api_helper.reply import Reply, SubReply
from api_helper.user import Activity, User, Token, Verify
from api_helper.message import Message
from api_helper.calendar import Calendar, Shift, SavedShift


import mongo as mongo
import logging

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

api.add_namespace(SearchList, "/search")
api.add_namespace(TotalSearchList, "/totalsearch")

api.add_namespace(Post, "/post")

api.add_namespace(Reply, "/reply")
api.add_namespace(SubReply, "/subreply")

api.add_namespace(User, "/user")
api.add_namespace(Token, '/refresh')
api.add_namespace(Activity, "/activity")
api.add_namespace(Verify, '/verify')

api.add_namespace(Message, "/message")
api.add_namespace(MessageList, "/messagelist")

api.add_namespace(Calendar, "/calendar")
api.add_namespace(Shift, '/shift')
api.add_namespace(SavedShift, '/savedshift')


import datetime
import time

from flask import g, request


@app.before_request
def start_timer():
    g.start = time.time()


# @app.after_request
# def log_request(response):

#     now = time.time()
#     duration = round(now - g.start, 6)  # to the microsecond
#     ip_address = request.headers.get("X-Forwarded-For", request.remote_addr)
#     host = request.host.split(":", 1)[0]
#     params = dict(request.args)

#     request_id = request.headers.get("X-Request-ID", "")

#     log_params = {
#         "method": request.method,
#         "path": request.path,
#         "status": response.status_code,
#         "duration": duration,
#         "ip": ip_address,
#         "host": host,
#         "params": params,
#         "request_id": request_id,
#     }
#     app.log.info("request", **log_params)

#     return response
# current_dir = os.path.dirname(os.path.realpath(__file__))
# log_dir = '{}/logs' .format(current_dir)
# if not os.path.exists(log_dir):
#         os.makedirs(log_dir)
# logging.basicConfig(filename = log_dir, level = logging.DEBUG)

@app.after_request
def log_request(response):
        log_str = """
        ipv4: {},
        url: {},
        method: {},
        params: {},
        status_code: {}
        """. format(request.remote_addr, request.full_path, request.method, request.get_data().decode(), response.status_code)
        
        return response



if __name__ == "__main__":
    print("__name__ == __main__")
    mongodb = mongo.MongoHelper()
    app.run(host="0.0.0.0", port="5000")
 
