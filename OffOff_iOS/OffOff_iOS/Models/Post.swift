//
//  Post.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

//"last_content_id": "60fff22fbf0d70004967d75b",
//    "post_list": [
//        {
//            "_id": "60fff22fbf0d70004967d75b",
//            "board_type": "promotion",
//            "Author": "박유진",
//            "Date": "2021-03-02T02:20:20",
//            "Title": "안녕하세요",
//            "Content": "맨 발로 걷고싶어 따사로운 햇볕아래 짐들을 풀어놓고 풀 가득한 공원에 마구 뛰어다니는 개들과 놀고싶어 어렸을적엔 잘 몰랐었어 누가 날 보던말던 I don't care at all 창피한줄도 몰라 훌훌벗고서 계곡 아래로 몸을 던져 camping everywhere 잔디 위로 누워 구름을 바라보다 잠들래 camping everywhere",
//            "image": null,
//            "Likes": 8,
//            "view_count": 4,
//            "report_count": 0,
//            "reply_count": 8
//        }
//    ]


struct PostList: Codable {
    var last_content_id: String
    var post_list: [PostModel]
}

struct PostModel: Codable {
    var _id: String
    var board_type: String
    var Author: String
    var Date: String
    var Title: String
    var Content: String
    var image: String?
    var Likes: Int
    var view_count: Int
    var report_count: Int
    var reply_count: Int
}

struct Post: Codable {
    var board_type: String
    var Author: String
    var Date: String
    var Title: String
    var Content: String
    var image: String?
    var Likes: Int
    var view_count: Int
    var report_count: Int
    var reply_count: Int
}
