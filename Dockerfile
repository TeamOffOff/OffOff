FROM python:3.7

ADD . /OffOff
WORKDIR /OffOff

RUN pip install -r requirements.txt
