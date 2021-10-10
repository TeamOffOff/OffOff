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
    var post = BehaviorSubject<PostModel?>(value: nil)
    var postDeleted = Observable<Bool>.just(false)
    var deleteButtonTapped = BehaviorSubject<UserModel?>(value: nil)
    var liked = BehaviorSubject<Bool>(value: false)
    
    var disposeBag = DisposeBag()
    var activityDisposeBag = DisposeBag()
    
    init(contentId: String, boardType: String, likeButtonTapped: Observable<(id: String, type: String)?>) {
        PostServices.fetchPost(content_id: contentId, board_type: boardType)
            .bind {
                self.post.onNext($0)
            }.disposed(by: disposeBag)
        
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
        
        likeButtonTapped
            .bind {
                if $0 != nil {
                    let post = PostActivity(boardType: boardType, _id: $0!.id, activity: "likes")
                    self.activityDisposeBag = DisposeBag()
                    PostServices.likePost(post: post).bind {
                        if $0 != nil {
                            self.post.onNext($0)
                            self.liked.onNext(true)
                        } else {
                            self.liked.onNext(false)
                        }
                        
                    }.disposed(by: self.activityDisposeBag)
                }
            }
            .disposed(by: disposeBag)
    }
}
