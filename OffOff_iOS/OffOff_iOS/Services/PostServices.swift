//
//  PostServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/12.
//

import Foundation
import Moya
import RxMoya
import RxSwift

public class PostServices {
    static let provider = MoyaProvider<PostAPI>()
    
    static func fetchPost(content_id: String, board_type: String) -> Observable<Post?> {
        PostServices.provider
            .rx.request(.getPost(content_id: content_id, board_type: board_type))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let response = try JSONDecoder().decode(Post.self, from: $0.data)
                    return response
                }
                return nil
            }
            .catchErrorJustReturn(nil)
    }
}
