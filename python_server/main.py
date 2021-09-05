from api_helper import create_app, socketio
import mongo

app = create_app(debug=True)


if __name__ == "__main__":
    mongodb = mongo.MongoHelper()
    socketio.run(app)
