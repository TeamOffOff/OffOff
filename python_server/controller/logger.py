import logging
import datetime
import logging.handlers
import os


def get_logger():

    # 현재 파일 경로 및 파일명 찾기
    current_dir = os.path.dirname(os.path.realpath(__file__))
    current_file = os.path.basename(__file__)
    current_file_name = current_file[:-3] #xxx.py
    LOG_FILENAME = 'log-{}' .format(current_file_name)

    # 로그 저장할 폴더 생성
    log_dir = '{}/logs' .format(current_dir)
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    # 로거 인스턴스 생성 및 이름 지정(로거 이름 지정)
    logger = logging.getLogger('OFFOFF')

    # 로거 수준 지정
    logger.setLevel(logging.DEBUG)

    # 자정이 되면 자동으로 로그 파일 생성(로그 파일이 생성된 날짜 기록)
    timed_file_handler = logging.handlers.TimedRotatingFileHandler(
        filename='logfile', when='midnight', interval=1, encoding='utf-8')
    
    timed_file_handler.suffix = "log-%Y%m%d" # 로그 파일명 날짜 기록 부분 포맷 지정
    logger.addHandler(timed_file_handler)

    # 로그 출력 포맷 지정
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - [%(filename)s:%(lineno)d] : %(message)s")
    timed_file_handler.setFormatter(formatter)  # 출력포맷 설정
    

    return logger
