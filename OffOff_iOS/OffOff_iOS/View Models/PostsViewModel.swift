//
//  PostsViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

import Foundation

class PostsViewModel {
    let posts: Box<[Post?]> = Box([])
    
    var count: Int {
        return posts.value.count
    }
    
    init() {
        fetchData()
        print(count)
    }
    
    func getPost(index: Int) -> Post? {
        return posts.value[index]
    }
    
    func fetchData() {
        // API Call 해서 해당 게시판의 데이터 받아오기
        let decoder = JSONDecoder()
        
        guard let jsonData = loadJsonFile() else {
            return
        }
        if let posts = try? decoder.decode([Post].self, from: jsonData) {
            print(posts.first?.metadata.title as Any)
            boxingData(posts: posts)
        }
        print(#fileID, #function, #line, "")
    }
    
    private func boxingData(posts: [Post]) {
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
}

