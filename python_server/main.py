from api_helper import create_app, socketio
import mongo
print("main.py 진입")

app = create_app(debug=True)
print("app:", app)


if __name__ == "__main__":
    print("__name__ == __main__")
    mongodb = mongo.MongoHelper()
    print("mongodb 실행 후")
    socketio.run(app)
