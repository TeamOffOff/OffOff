//
//  PostsViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

import Foundation

class PostsViewModel {
    let posts: Box<[PostModel?]> = Box([])
    
    var count: Int {
        return posts.value.count
    }
    
    init() {
        fetchData()
    }
    
    func getPost(index: Int) -> PostModel? {
        return posts.value[index]
    }
    
    // TODO: 특정 게시판의 데이터를 파싱
    func fetchData() {
        // API Call 해서 해당 게시판의 데이터 받아오기
        let decoder = JSONDecoder()
        
        guard let jsonData = loadJsonFile() else {
            return
        }
        if let posts = try? decoder.decode([PostModel].self, from: jsonData) {
            boxingData(posts: posts)
        }
        print(#fileID, #function, #line, "")
    }
    
    private func boxingData(posts: [PostModel]) {
        posts.forEach {
            self.posts.value.append($0)
        }
    }
    
    // local json 파일 가져오기
    private func loadJsonFile() -> Data? {
        guard let path = Bundle.main.url(forResource: "PostsDummyData", withExtension: "json") else {
            return nil
        }
        
        guard let jsonData = try? Data(contentsOf: path) else {
            return nil
        }
        
        return jsonData
    }
    
    // TODO: 새로운 포스트 게시
    static func makeNewPost(title: String, content: String, board_type: String) {
        let metadata = Metadata(author: "홍길동", title: title, date: Date().toString(), board_type: board_type, preview: "preview")
        let newPost = PostModel(content_id: "Test_id", metadata: metadata, contents: Contents(content: content))
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(newPost)
        
        #if DEBUG
        if let jsonData = data, let jsonString = String(data: jsonData, encoding: .utf8){
            print(jsonString)
        }
        #endif
        
    }
}

