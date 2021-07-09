//
//  Post.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

/*
{
  "content_id": "1",
  "metadata": {
    "author": "ABC",
    "title": "CVC",
    "date": "qow",
    "board_type": "자유게시판",
    "preview": "동해물과 백두산이",
    "likes": "0",
    "view_count": "0",
    "report_count": "0",
    "reply_count": "0"
  },
  "contents": {
    "content": "Lorem Ipsum is simply dummy text of the printing and typesetting <image1> industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
  }
}
*/

struct PostModel: Codable {
    var content_id: String
    var metadata: Metadata
    var contents: Contents
}

struct Contents: Codable {
    var content: String
}

struct Metadata: Codable {
    var author: String
    var title: String
    var date: String
    var board_type: String
    var preview: String
    var likes: Int = 0
    var view_count: Int = 0
    var report_count: Int = 0
    var reply_count: Int = 0
}
