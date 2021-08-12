//
//  PostViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/09.
//

import Foundation
import RxSwift

class PostViewModel {
    let post: Observable<PostModel?>
    
    init(contentId: String, boardType: String) {
        post = PostServices.fetchPost(content_id: contentId, board_type: boardType)
    }
}
