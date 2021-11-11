from flask import Flask, request
from flask_restx import Api
from controller.logger import get_logger
import logging

from flask_jwt_extended import JWTManager

from api_helper.utils import APP_SECRET_KEY, JWT_SECRET_KEY

from api_helper.list import BoardList, PostList, UserControl, MessageList, SearchList, TotalSearchList
from api_helper.post import Post
from api_helper.reply import Reply, SubReply
from api_helper.user import Activity, User, Token, Verify
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


@app.after_request
def log_request(response):
        # 어떤 파일에서 로깅 됐는지 알기 위해  __name__으로
        import logging
        f_handler = logging.FileHandler('train.log')
        f_handler.setLevel(logging.DEBUG)  # 파일에 저장할 레벨을 별도로 설정할 수 있음
        f_format = logging.Formatter('%(asctime)s - %(name)s: %(lineno)4d - %(levelname)s - %(message)s')
        f_handler.setFormatter(f_format)

        # Add handlers to the logger
        logger = logging.getLogger()
        logger.addHandler(f_handler)

        log_str = """
        ipv4: {},
        url: {},
        method: {},
        params: {},
        status_code: {}
        """. format(request.remote_addr, request.full_path, request.method, request.get_data().decode(), response.status_code)
        
        logger.info(log_str)
        # try-except Exception으로 에러 로깅 -> logger.exception('Exception occured')
        # 내가 if 문, try-except 등을 활용해서 warning, error 등을 로깅하는 거??
        
        return response



if __name__ == "__main__":
        logger = logging.getLogger(__name__)
        logging.basicConfig(  # basicConfig는 main에서만 함
                format = "%(asctime)s - %(name)s - %(levelname)s - [%(lineno)d] : %(message)s",
                level="INFO"
        )

        try:
                mongodb = mongo.MongoHelper()
                app.run(host="0.0.0.0", port="5000")
        except Exception:
                logger.exception("Exception occured")
 
