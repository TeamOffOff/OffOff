import base64
import time
import uuid

import boto3
from api_helper.utils import *
from botocore.exceptions import ClientError

s3 = boto3.resource("s3",
                    aws_access_key_id=AWS_ACCESS_KEY_ID,
                    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                    region_name=AWS_DEFAULT_REGION)

bucket = s3.Bucket("offoffbucket")
resize_bucket = s3.Bucket("offoffbucket-resize")


def save_image(img_list: list, directory: str):
    key_list = []

    if not img_list:
        return None

    img_key = ""
    for img in img_list:
        img_key = str(uuid.uuid4()) + ".jpg"
        key_list.append(img_key)
        print("img_key: ", img_key)

        img_body = base64.b64decode(img["body"])
        img_obj = s3.Object(bucket.name, directory + "/" + img_key)

        img_obj.put(Body=img_body)

    start = time.time()
    time_limit = 5.0

    while True:
        try:
            print("check image saved...")
            _ = s3.Object(resize_bucket.name, directory + "/600/" + img_key).load()
            print("Image Saved: {} sec".format(time.time() - start))
            break
        except ClientError as e:
            if time.time() - start > time_limit:
                raise Exception("fail to save image")

            if e.response['Error']['Code'] == "404":
                time.sleep(0.5)
                print("image have been not saved yet")
                continue
            else:
                print(e)

    return key_list


def get_image(img_key_list: list, directory: str, img_size: str = "origin"):  # "post","user" / "origin", "200","600"
    img_list = list()

    if not img_key_list:
        return []

    for img_key in img_key_list:
        if img_size == "origin":
            print("Get original Image from {}".format(directory + "/" + img_key))
            img_obj = s3.Object(bucket.name, directory + "/" + img_key)
        else:
            print("Get resized Image from {}".format(directory + "/" + img_size + "/" + img_key))
            img_obj = s3.Object(resize_bucket.name, directory + "/" + img_size + "/" + img_key)
        img = img_obj.get()["Body"].read()
        img_body = str(base64.b64encode(img), 'utf-8')

        img_list.append({
            "key": img_key,
            "body": img_body
        })

    return img_list


def delete_image(img_key_list: list, directory: str):
    possible_size = ["origin", "200", "600"]

    try:
        for img_key in img_key_list:
            for img_size in possible_size:
                if img_size == "origin":
                    s3.Object(bucket.name, directory + "/" + img_key).delete()
                else:
                    s3.Object(resize_bucket.name, directory + "/" + img_size + "/" + img_key).delete()
            print(f"Image <{img_key}> have been deleted")
    except Exception as e:
        print(f"Images cannot be deleted by exception: {e}")
