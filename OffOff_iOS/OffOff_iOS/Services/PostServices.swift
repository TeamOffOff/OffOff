//
//  PostServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/12.
//

import Foundation
import Alamofire

public class PostServices {
    static let source = "http://localhost:4000/GetPosts"
    
    // 어떤 게시판인지, 어떤 포스트부터 받을지를 정하고, 포스트 목록 받아오기
    static func fetchPostList(completion: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request(source + "/postlist", method: .get).responseJSON(completionHandler: completion)
    }
}
