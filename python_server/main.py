from flask import Flask  # 서버 구현을 위한 Flask 객체 import
from flask_restx import Api

import mongo
from api_helper.board import BoardList, PostList
from api_helper.post import Post
from api_helper.user_copy import Auth

app = Flask(__name__)
api = Api(app)

api.add_namespace(Post, "/post")
api.add_namespace(BoardList, "/boardlist")
api.add_namespace(PostList, "/postlist")
api.add_namespace(Auth, "/Auth")


if __name__ == "__main__":
    mongodb = mongo.MongoHelper()
    app.run(debug=True, host="0.0.0.0", port=5000)

    # pip install h5py==2.10.0 --force-reinstall
    # pip install markdown==3.2.2
    # pip install h5py==2.10.1

