from pymongo import MongoClient
from pymongo.cursor import CursorType


class MongoHelper:
    def __init__(self, db_name="test_db", collection_name="test_collection"):
        print("Run MongoDB")
        self.host = "localhost"
        self.port = 27017
        self.client = MongoClient(self.host, self.port)
        self.db = self.client[db_name]
        self.collection = self.db[collection_name]

    def insert_one(self, data=None):
        result = self.collection.insert_one(data).inserted_id
        return result

    def insert_many(self, data=None):
        result = self.collection.insert_many(data).inserted_ids
        return result

    def find_one(self, query=None):
        result = self.collection.find_one(query)
        return result

    def find(self, query=None):
        result = self.collection.find(query)
        return result

    def delete_one(self, query=None):
        result = self.collection.delete_one(query)
        return result

    def delete_many(self, query=None):
        result = self.collection.delete_many(query)
        return result


if __name__ == "__main__":
    mongodb = MongoHelper()

    print(mongodb.insert_one({"test": "hi"}))
    for string in mongodb.find():
        print(string)
    print(mongodb.delete_many({"test": "hi"}))
    for string in mongodb.find():
        print(string)
