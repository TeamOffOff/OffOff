//
//  PostViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/09.
//

import Foundation
import RxSwift
import RxCocoa

class PostViewModel {
    let post: Observable<PostModel?>
    let postDeleted: Observable<Bool>
    var deleteButtonTapped = BehaviorSubject<UserModel?>(value: nil)
    
    init(contentId: String, boardType: String) {
        post = PostServices.fetchPost(content_id: contentId, board_type: boardType)
        postDeleted = Observable.combineLatest(post, deleteButtonTapped)
            .debug()
            .filter { $0.1 != nil && $0.0 != nil }
            .flatMap { val -> Observable<Bool> in
                if val.0!.author._id == val.1!._id {
                    // TODO: delete 안됨
                    return PostServices.deletePost(post: DeletingPost(_id: val.0!._id!, boardType: val.0!.boardType, author: val.0!.author._id!))
                } else {
                    return Observable.just(false)
                }
            }
    }
}
