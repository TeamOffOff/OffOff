from flask import request, session
from flask_restx import Resource, Namespace
from bson.objectid import ObjectId
from datetime import datetime, timedelta

from pymongo import collection

import mongo

from flask_socketio import emit, join_room, leave_room, Namespace




# 소켓통신
class ChatNamepsace(Namespace):
    
    def on_connect(self):
        pass

    def on_disconnect(self):
        pass

    def on_joined(self, data):
        room = session.get('room')
        join_room(room)
        emit('status', {'msg': session.get('name') + '님이 입장하셨습니다'}, room=room)

    def on_text(self, data):
        room = session.get('room')
        emit('message', {'msg': session.get('name') + ':' + data['msg']}, room=room)

    def on_left(self, data):
        room = session.get('room')
        leave_room(room)
        emit('status', {'msg': session.get('name') + '님이 퇴장하셨습니다'}, room=room)