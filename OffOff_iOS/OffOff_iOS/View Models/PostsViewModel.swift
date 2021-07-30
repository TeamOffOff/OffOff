//
//  PostsViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

import Foundation
import Alamofire

class PostsViewModel {
    let postList: Box<PostList?> = Box(nil)
    
    var count: Int {
        return postList.value?.post_list.count ?? 0
    }
    
    init() {
        
    }
    
    func getPost(index: Int) -> PostModel? {
        return postList.value?.post_list[index]
    }
    
    func fetchPost(index: Int, completion: @escaping (PostModel) -> Void) {
        fetchPost(content_id: postList.value?.post_list[index]._id ?? "", board_type: postList.value?.post_list[index].board_type ?? "", completion: completion)
    }
    
    func fetchPost(content_id: String, board_type: String, completion: @escaping (PostModel) -> Void) {
        PostServices.fetchPost(content_id: content_id, board_type: board_type) { (post) in
            completion(post)
        }
    }
    
    // 특정 게시판의 데이터를 파싱
    func fetchPostList(board_type: String) {
        PostServices.fetchPostList(board_type: board_type) { (postList) in
            self.postList.value = postList
        }
    }
    
//    static func makeNewPost(title: String, content: String, board_type: String) {
//        let metadata = Metadata(author: "홍길동", title: title, date: Date().toString(), board_type: board_type, preview: "preview")
//        let newPost = PostModel(content_id: "MoyaTest", metadata: metadata, contents: Contents(content: content))
//
//        PostServices.makeNewPost(post: newPost) { (post, error) in
//            if error == nil {
//                print("Created New Post Successfully:\n\(post)")
//            }
//        }
//    }
}
