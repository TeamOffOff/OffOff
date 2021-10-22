from pyfcm import FCMNotification
from api_helper.utils import FCM_API_KEY

API_KEY = FCM_API_KEY
push_service = FCMNotification(api_key=API_KEY)


def sendMessage(device_token, message, data):
    """
    device_token = 개별 기기의 토큰
    message = {
        "title": "",
        "body": ""
    data = 사용자가 push 알람을 클릭해서 앱으로 들어왔을 때 어떤 화면을 보여줄 것인지
    """
    title = message["title"]
    body = message["body"]

    result = push_service.notify_single_device(
        register_id=device_token, 
        messgae_title=title, 
        message_body=body, 
        data_message=data
        )

    print(result)
