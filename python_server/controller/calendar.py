from flask import request
from bson.objectid import ObjectId

import mongo as mongo

mongodb = mongo.MongoHelper()

def calendar_post_or_delete(field, operator):
    request_info = request.get_json()
    calendar_id = request_info["_id"]
    content = request_info["content"]
    result = mongodb.update_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar", modify={operator:{field: content}})
    return result


def calendar_update(field, operator):
    request_info = request.get_json()
    calendar_id = request_info["_id"]
    content = request_info["content"]
    shift_id = content["id"]
    result = mongodb.update_one(query={"_id": ObjectId(calendar_id)}, collection_name="calendar", modify={operator:{f"{field}.$[elem]":content}}, array_filters=[{"elem.id":shift_id}])
    return result


