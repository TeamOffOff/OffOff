from pymongo import MongoClient, collection
from pymongo.cursor import CursorType


class MongoHelper:
    def __init__(self, db_name="test_db"):
        print("Run MongoDB")
        self.host = "localhost"
        self.port = 27017
        self.client = MongoClient(self.host, self.port)
        self.db = self.client[db_name]
        self.collection = None
    

    def insert_one(self, data=None, collection_name=None):
        self.collection = self.db[collection_name]
        result = self.collection.insert_one(data).inserted_id
        return result

    def insert_many(self, data=None, collection_name=None):
        self.collection = self.db[collection_name]
        result = self.collection.insert_many(data).inserted_ids
        return result

    def find_one(self, query=None, collection_name=None, projection_key=None):
        self.collection = self.db[collection_name]
        result = self.collection.find_one(query, projection_key)
        return result

    def find(self, query=None, collection_name=None, projection_key=None):
        self.collection = self.db[collection_name]
        result = self.collection.find(query, projection_key)
        return result

    def delete_one(self, query=None, collection_name=None):
        self.collection = self.db[collection_name]
        result = self.collection.delete_one(query)
        return result

    def delete_many(self, query=None, collection_name=None):
        self.collection = self.db[collection_name]
        result = self.collection.delete_many(query)
        return result

    def update_one(self, query=None, collection_name=None, modify=None, upsert=False, bypass=False, collation=None, array_filters=None):
        self.collection = self.db[collection_name]
        result = self.collection.update_one(query, modify, upsert, bypass, collation, array_filters)
        return result

    def update_many(self, query=None, collection_name=None, modify=None):
        self.collection = self.db[collection_name]
        result = self.collection.update_many(query, modify, upsert=False)
        return result
    
    def aggregate(self, pipeline=None, collection_name=None):
        self.collection = self.db[collection_name]
        result = self.collection.aggregate(pipeline)
        return result
    
    def drop(self, collection_name=None):  # 컬렉션 자체를 없앰
        self.collection = self.db[collection_name]
        result = self.collection.drop()
        return result



if __name__ == "__main__":
    mongodb = MongoHelper()
    print(mongodb.insert_one({"test": "hi"}))
    for string in mongodb.find():
        print(string)
    print(mongodb.delete_many({}))
    for string in mongodb.find():
        print(string)