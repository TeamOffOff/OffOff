from flask import Flask, request
from flask_restx import Api
from controller.logger import get_logger
import logging

from flask_jwt_extended import JWTManager, jwt_required

from api_helper.utils import APP_SECRET_KEY, JWT_SECRET_KEY

from api_helper.list import BoardList, PostList, MessageList, SearchList, TotalSearchList, Activity
from api_helper.post import Post, TestPost
from api_helper.reply import Reply, SubReply
from api_helper.user import  User, Token, Verify
from api_helper.message import Message
from api_helper.calendar import Calendar, Shift, SavedShift
from api_helper.test import UserControl 


import mongo as mongo

app = Flask(__name__)

app.config.update(
        DEBUG=True,
        SECRET_KEY = APP_SECRET_KEY,
        JWT_SECRET_KEY = JWT_SECRET_KEY,
        
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
api.add_namespace(TestPost, '/testpost')

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


# logging 부분
@app.after_request
def log_request(response):
        # 어떤 파일에서 로깅 됐는지 알기 위해  __name__으로
        import logging
        f_handler = logging.FileHandler('train.log')
        f_handler.setLevel(logging.DEBUG)  # 파일에 저장할 레벨을 별도로 설정할 수 있음
        f_format = logging.Formatter('[%(asctime)s] %(levelname)s - %(message)s')
        f_handler.setFormatter(f_format)

        # f_format = logging.Formatter('[%(asctime)s] %(levelname)s - %(name)s %(lineno)4d - %(message)s')
        # 여기에서 실행하는 name -> __main__  // lineno -> logger.info 하는 부분
        
       # name 지정 
        logger = logging.getLogger(__name__)  

        # Add handlers to the logger
        logger.addHandler(f_handler)
        
        # baes 64 없애기 위한 로직
        logging_info = request.get_json() #get_data().decode() 이렇게 하면 str형태임
        
        if logging_info:  # get 이외의 요청
                if "image" in logging_info:  # image key가 있다 == 게시글 작성 관련 요청
                        if logging_info["image"]: # 게시글 작성에서 이미지 업로드
                                logging_info["image"] = "사진업로드함"
                elif "subInformation" in logging_info:  #subInformation key가 있다 == 회원가입 관련 요청
                        if logging_info["subInformation"]["profileImage"]: # 회원가입시 profileImage 업로드
                                logging_info["subInformation"]["profileImage"] = "프로필 사진 업로드 함"

        # 저장할 정보
        log_str = """
        status_code: {0}
        ipv4: {1},
        url: {2},
        method: {3},
        content: {4}
        """. format(response.status_code, request.remote_addr, request.full_path, request.method, logging_info)

        # try-except Exception으로 에러 로깅 -> logger.exception('Exception occured')
        # 내가 if 문, try-except 등을 활용해서 warning, error 등을 로깅하는 거??
        try:
                if response.status_code == 200:
                        logger.debug(log_str)
                        logger.info(log_str)
                else:
                        logger.warning(log_str)
        except Exception:  # 이 부분이 안 됨!!!!!!! 
                logger.exception("EXCEPTION OCCURED")
        
        return response


logger = logging.getLogger(__name__)
logging.basicConfig(  # basicConfig는 main에서만 함
        format = "main.py -> [%(asctime)s] %(levelname)s - NAME %(name)s -  LINE%(lineno)d - %(message)s",
        level="INFO"
)


if __name__ == "__main__":
        
        try:
                mongodb = mongo.MongoHelper()
                app.run(host="0.0.0.0", port="5000")
        except Exception:
                logger.exception("Exception occured")
 
