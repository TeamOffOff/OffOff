from flask import Flask, request, jsonify  # 서버 구현을 위한 Flask 객체 import
from flask_restx import Api, Resource

app = Flask(__name__)
api = Api(app)


@api.route("/SignUp")
class SignUp(Resource):
    pass


@api.route("/SignIn")
class SignIn(Resource):
    pass


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")