import boto3
import base64

from api_helper.utils import *

s3 = boto3.resource("s3",
                    aws_access_key_id=AWS_ACCESS_KEY_ID,
                    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                    region_name=AWS_DEFAULT_REGION)

bucket = s3.Bucket("offoffbucket")


def save_image(img_list: list, directory: str):
    key_list = []

    if not img_list:
        return None

    for img in img_list:
        img_key = img["key"]
        key_list.append(img_key)
        print("img_key: ", img_key)

        img_body = base64.b64decode(img["body"])
        img_obj = s3.Object(bucket.name, directory + "/" + img_key)

        img_obj.put(Body=img_body)
        print("Image Saved")

    return key_list


def get_image(img_key_list: list, directory: str):
    img_list = list()

    if not img_key_list:
        return None

    for img_key in img_key_list:
        img_obj = s3.Object(bucket.name, directory + "/" + img_key)
        img = img_obj.get()["Body"].read()
        img_body = str(base64.b64encode(img), 'utf-8')

        img_list.append({
            "key": img_key,
            "body": img_body
        })

    return img_list
