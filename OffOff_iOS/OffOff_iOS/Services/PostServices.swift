//
//  PostServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/12.
//

import Foundation
import Alamofire
import Moya

public class PostServices {
    typealias PostListCompletion = ([PostModel]?, AFError?) -> ()
    typealias MakeNewPostCompletion = (PostModel, AFError?) -> ()
    static let source = "http://localhost:4000/GetPosts"
    
    // 어떤 게시판인지, 어떤 포스트부터 받을지를 정하고, 포스트 목록 받아오기
    static func fetchPostList(completion: @escaping PostListCompletion) {
        AF.request(source, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let result):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    let json = try JSONDecoder().decode([PostModel].self, from: jsonData)
                    completion(json, nil)
                } catch(let error) {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print("Underlying error: \(error.errorDescription!)")
                completion(nil, error)
            }
        }
    }
    
    // TODO: 새로운 포스트 게시
    static func makeNewPost(post: PostModel, completion: @escaping MakeNewPostCompletion) {
        let provider = MoyaProvider<CommunityAPI>()
        provider.request(.newPost(post)) { (result) in
            switch result {
            case let .success(response):
                print(response.request)
                print(try? response.mapJSON())
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
//        #if DEBUG
//        let source = "http://3.34.138.102:5000/post/content-id=\(post.content_id)"
//        AF.request(source, method: .put, parameters: post, encoder: JSONParameterEncoder.default).response { (response) in
//            print(response)
//            completion(post, response.error)
//        }
//        #endif
    }
}
