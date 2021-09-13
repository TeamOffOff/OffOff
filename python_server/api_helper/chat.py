from flask import request, session
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from datetime import datetime, timedelta

from pymongo import collection

import python_server.mongo as mongo

from flask_socketio import emit, join_room, leave_room, Namespace

mongodb = mongo.MongoHelper()


# 소켓통신
class ChatNamepsace(Namespace):
    
    def on_connect(self):
        pass

    def on_disconnect(self):
        pass

    def on_joined(self, data):
        pass

    def on_text(self, data):
        pass

    def on_left(self, data):
        pass