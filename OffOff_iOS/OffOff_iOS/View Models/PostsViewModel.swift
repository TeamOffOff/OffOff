//
//  PostsViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

import Foundation
import Alamofire

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
        PostServices.fetchPostList { [weak self] (posts, error) in
            guard let self = self, let posts = posts else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            self.boxingData(posts: posts)
        }
        print(#fileID, #function, #line, "")
    }
    
    private func boxingData(posts: [PostModel]) {
        posts.forEach {
            self.posts.value.append($0)
        }
    }
    
    static func makeNewPost(title: String, content: String, board_type: String) {
        let metadata = Metadata(author: "홍길동", title: title, date: Date().toString(), board_type: board_type, preview: "preview")
        let newPost = PostModel(content_id: "MoyaTest", metadata: metadata, contents: Contents(content: content))
        
        PostServices.makeNewPost(post: newPost) { (post, error) in
            if error == nil {
                print("Created New Post Successfully:\n\(post)")
            }
        }
    }
}

