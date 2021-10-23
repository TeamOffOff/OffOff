import logging
import datetime
import logging.handlers
import os


def __get_logger():
    """
    로거 인스턴스 반환
    """

    # 현재 파일 경로 및 파일명 찾기
    current_dir = os.path.dirname(os.path.realpath(__file__))
    current_file = os.path.basename(__file__)
    current_file_name = current_file[:-3] #xxx.py
    LOG_FILENAME = 'log-{}' .format(current_file_name)

    # 로그 저장할 폴더 생성
    log_dir = '{}/logs' .format(current_dir)
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)



    # 로거 인스턴스 생성 및 이름 지정
    __logger = logging.getLogger('OFFOFF')

    # 로거 수준 지정
    __logger.setLevel(logging.DEBUG)

    # 로그 출력 포맷 지정
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - [%(filename)s:%(lineno)d] : %(message)s")

    # message에 나오는 부분
    # -> api요청이  들어올 때마다 message를 생성하도록 해야함
    # __logger.debug("DEBUG")
    # __logger.info("INFO" )
    # __logger.warn("WARN")

    # stream_handler = logging.StreamHandler()
    # stream_handler.setFormatter(formatter)
    # __logger.addHandler(stream_handler)

    # file_handler = logging.FileHandler('C:\\test\\logfile_{:%Y%m%d}.log'. format(datetime.datetime.now()), encoding='utf-8')
    # file_handler.setFormatter(formatter)
    # __logger.addHandler(file_handler)

    # 자정이 되면 자동으로 로그 파일 생성(로그 파일이 생성된 날짜 기록)
    timed_file_handler = logging.handlers.TimedRotatingFileHandler(
        filename='logfile', when='midnight', interval=1, encoding='utf-8')
    timed_file_handler.setFormatter(formatter)  # 출력포맷 설정
    timed_file_handler.suffix = "log-%Y%m%d" # 로그 파일명 날짜 기록 부분 포맷 지정
    __logger.addHandler(timed_file_handler)

    return __logger

    

# if not app.debug :
#         # 여기 지금 작동 안 함 ㅠㅠ
#         # logging
#         logger = logging.getLogger(__name__)
#         logger.setLevel(logging.DEBUG)

#         formatter = logging.Formatter(fmt='%(asctime)s:%(module)s:%(levelname)s:%(message)s', datefmt='%Y-%m-%d %H:%M:%S')

#         # INFO 레벨 이상의 로그를 콘솔에 출하는 Handler
#         console_handler = logging.StreamHandler()
#         console_handler.setLevel(logging.INFO)
#         console_handler.setFormatter(formatter)
#         logger.addHandler(console_handler)

#         # DEBUG 레벨 이상의 로그를 'debug.log'에 출력하는 Handler
#         file_debug_handler = logging.FileHandler('debug.log')
#         file_debug_handler.setLevel(logging.DEBUG)
#         file_debug_handler.setFormatter(formatter)
#         logger.addHandler(file_debug_handler)

#         # ERROR 레벨 이상의 로그를 'error.log'에 출력하는 Handler
#         file_error_handler = logging.FileHandler('error.log')
#         file_error_handler.setLevel(logging.ERROR)
#         file_error_handler.setFormatter(formatter)
#         logger.addHandler(file_error_handler)   