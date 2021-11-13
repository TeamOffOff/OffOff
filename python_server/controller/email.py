import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from api_helper.utils import GMAIL_ID,GMAIL_PW

def send_email(r_email, verify, message):
    data = MIMEMultipart()
    data["From"] = "TeamOffPublic@gmail.com"
    data["To"] = r_email
    # data["Cc"] = cc
    # data["Bcc"] = bcc
    data["Subject"] = "Test Mail"

    html_msg = "<h1>메일인증</h1>" + "<h2><a href = '" + verify + "'>" + "확인</a></h2>" + message

    msg = MIMEText(html_msg, 'html')
    data.attach(msg)

    server = smtplib.SMTP_SSL('smtp.gmail.com', 465)

    # debug 내용이 output.txt에 기록되지 않고 terminal에 출력됨 -> 문제발생 
    # server.set_debuglevel(1)

    server.ehlo()
    server.login(GMAIL_ID, GMAIL_PW)
    server.ehlo()

    sender = data["From"]
    receiver = data["To"]

    server.sendmail(sender, receiver, data.as_string())
    # 잘못된 주소로 보내라고 하면 에러 메시지 보낼 것
    # 시간 지나고 난 다음에는 해당 링크가 안 먹히도록 할 것
    
    server.quit()




# from email.message import EmailMessage

# class Gmail_sender:
#     def __init__(self, sender_email, receiver_email, sender_password, cc_email="", bcc_email=""):
#         self.s_email = sender_email
#         self.r_email = receiver_email
#         self.pw = sender_password
#         self.server_name = "smtp.gmail.com"
#         self.server_port = 587  #587은 TLS 암호화, 465는 SSL 암호화

#         self.msg = EmailMessage()
#         self.msg["From"] = self.s_email
#         self.msg["To"] = self.r_email
#         if cc_email != "":
#             self.cc_email = cc_email
#             self.msg["Cc"] = self.cc_email
#         if bcc_email != "":
#             self.bcc_email = bcc_email
#             self.msg["Bcc"] = self.bcc_email
#         self.smtp = smtplib.SMTP(self.server_name, self.server_port)

#     def msg_set(self, msg_title, msg_body):
#         self.msg["Subject"] = msg_title
#         self.msg.set_content(msg_body)
    
#     def smtp_connect_send(self):
#         self.smtp.ehlo()  # 연결확인
#         self.smtp.starttls()  # TLS 활성화
#         self.smtp.login(self.s_email, self.pw)  # 서버에 로그인
#         self.smtp.send_message(self.msg)  # 메시지 보내기
    
#     def smtp_disconnect(self):
#         self.smtp.close()