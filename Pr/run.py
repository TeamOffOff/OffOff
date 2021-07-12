from flask import Flask
from flask import request
from flask import render_template
from flask_pymongo import PyMongo
from datetime import datetime 
from bson.objectid import ObjectId
from flask import abort
from flask import redirect
from flask import url_for
import time
import math

app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb://localhost:27017/myweb"
mongo = PyMongo(app)


# 시간 필터
@app.template_filter("formatdatetime") #데코레이터
def format_datetime(value) :
    if value is None :
        return ""
    
    now_timestamp = time.time() #클라이언트가 게시글을 보고 있는 시간
    offset = datetime.fromtimestamp(now_timestamp)  - datetime.utcfromtimestamp(now_timestamp)
    value = datetime.fromtimestamp((int(value)/1000) + offset)
    return value.strftime("%Y-%m-%d %H:%M:%S")


#리스트에서 클릭했을 때 해당 상세페이지로 들어가면서 idx를 같이 줘야함 (wirte -> view) 넘어가는 것처럼
@app.route("/list")
def lists() :
    #페이지 값(값이 없는 경우 기본값은 1)
    page = request.args.get("page", default = 1, type = int) #argument로 page값이 넘어오면 그걸 쓰는데 안 넘어오면 1
    
    #한 페이지당 몇 개의 게시물을 출력할지
    limit = request.args.get("limit", 10, type =int)

    board = mongo.db.board
    tot_count = board.find({}).count() #게시물 갯수
    last_page_num = math.ceil(tot_count / limit) #limit로 나눠서 올림하니까 총 있어야하는 페이지수
    block_size =5 #페이지블럭 5개씩 표기 
    block_num = int((page-1)/block_size) #현재블럭 위치
    block_start = int((block_size * block_num) +1 ) #블럭 시작 위치 1/6/11
    block_last = math.ceil((block_start + (block_size-1))) #math.ceil은 왜하는거지 ?
    datas = board.find({}).skip((page-1)*limit).limit(10)  #전체 게시물을 가져옴 앞에 건 스킵함
    return render_template("list.html", datas=datas, limit=limit, page=page, block_start=block_start, block_last=block_last, last_page_num=last_page_num) #datas(전)에  datas(위에서 선언)를 넣어서 보내줌


# 상세페이지 보기
@app.route("/view/<idx>") #fancy url 방식
def board_view(idx): #글작성시 idx를 넘겨줌
    # idx = request.args.get("idx") #view?idx=1234 (get방식) <-fancy방식 아니면 이렇게 나옴
    if idx is not None :
        board = mongo.db.board
        data = board.find_one({"_id" : ObjectId(idx)})

        if data is not None :
            result = {
                "id" : data.get("_id"),
                "name" : data.get("name"),
                "title" : data.get("title"),
                "contents" : data.get("contents"),
                "pubdate" : data.get("pubdate"),
                "view" : data.get("view")
            }

            return render_template("view.html", result=result) #앞에 있는 result가 html로 넘어감
    
    return abort(404)


# 글 작성
@app.route("/write", methods=["GET", "POST"])
def board_wirte() :
    if request.method =="POST":
        name = request.form.get("name")
        title = request.form.get("title")
        contents = request.form.get("contents")
        # print(name, title, contents)
        current_utc_time = round(datetime.utcnow().timestamp() * 1000)
        
        #컬랙션
        board = mongo.db.board
        post = {
            "name": name, 
            "title": title,
            "contents": contents
            "pubdate": current_utc_time, 
            "view": 0,
        }

        x = board.insert_one(post)

        print(x.inserted_id)

        return redirect(url_for("board_view", idx=x.inserted_id)) #board_view함수가 가리키는 url로 연결시킴 해당 함수의 idx라는 변수에 어떤 값을 넣어줄지도 정할 수 있음

    else : #get으로 요청이 왔을 때
        return render_template("write.html") #write.html을 그냥 보여줌


# 글 수정 => 상세페에지에서 글 수정 누르니까 idx를 그대로 받아올 수 있음??
@app.route("/edit/<idx>", ,methods=["GET", "POST"])
def board_edit(idx):
    if request.method == "GET" :
        board = mongo.db.board
        data = board.find_one({"_id" : ObjectId(idx)}) #mongodb는 _id가 object형태
        if data is None :
            return redirect(url_for("lists")) #리스트 아직 안 만듦
        else : 
            if session.get("id") == data.get("writer_id") : #session의 아이디는 작성자, writer의 id 는 현재 접근한 사람
                return render_template("edit.html", data=data)
            else : 
                return redirect(url_for("lists"))
    
    else :
        title = request.form.get("title")
        contents = request.form.get("contents")

        board = mongo.db.board
        data = board.find_one({"_id" : ObjectId(idx)}
        if session.get("id") == data.get("writer_id") : 
            borad.update_one({"_id" : ObjectId(idx)}, {
                "$set" : {
                    "title" : title,
                    "contents" : contents,
                }
            })
            return redirect(url_for("board_view", idx=idx)) #수정한 다음 상세페이지로
        else : 
            return redirect(url_for("lists"))


#글 삭제 => 상세페에지에서 글 수정 누르니까 idx를 그대로 받아올 수 있음??
@app.route("/delete/<idx>") #fancy방식
def board_delete(idx) :
    board = mongo.db.board
    data = board.find_one({"_id" : ObjectId(idx)})

    if data.get("writer_id") == sesson.get("id"):
        board.delete_one({"_id" : ObjectId(idx)})
    else : 
    
    return redirect(url_for("lists")) #삭제 되었든 안 되었든



if __name__ =="__main__" :
    app.run(host="0.0.0.0", debug=True, port=9000)

