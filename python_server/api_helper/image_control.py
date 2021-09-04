import boto3
import base64
from .utils import *

s3 = boto3.resource("s3",
                    aws_access_key_id=AWS_ACCESS_KEY_ID,
                    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                    region_name=AWS_DEFAULT_REGION)

bucket = s3.Bucket("offoffbucket")


def save_image(img: dict, directory: str):
    img_key = img["key"]
    img_body = base64.b64decode(img["body"])

    img_obj = s3.Object(bucket, directory + "/" + img_key)
    img_obj.put(Body=img_body)


def get_image(img_key: str):
    img_obj = s3.Object(bucket, img_key)
    img = img_obj.get()["Body"].read()
    img = str(base64.b64decode(img), 'utf-8')

    return img
