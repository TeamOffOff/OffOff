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
    var replies = BehaviorSubject<[Reply]?>(value: nil)
    
    var deleteButtonTapped = BehaviorSubject<UserModel?>(value: nil)
    var liked = BehaviorSubject<Bool>(value: false)
    var replyAdded = BehaviorSubject<Bool>(value: false)
    
    var disposeBag = DisposeBag()
    var activityDisposeBag = DisposeBag()
    
    init(contentId: String, boardType: String, likeButtonTapped: Observable<(id: String, type: String, cell: PostPreviewCell)?>, commentButtonTapped: Observable<WritingReply>) {
        ReplyServices.fetchReplies(of: contentId, in: boardType)
            .bind {
                self.replies.onNext($0)
            }.disposed(by: disposeBag)
        
        PostServices.fetchPost(content_id: contentId, board_type: boardType)
            .bind {
                self.post.onNext($0)
            }.disposed(by: disposeBag)
        
        
        
        postDeleted = Observable.combineLatest(post, deleteButtonTapped)
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
            .bind { val in
                if val != nil {
                    let post = PostActivity(boardType: boardType, _id: val!.id, activity: "likes")
                    self.activityDisposeBag = DisposeBag()
                    PostServices.likePost(post: post).bind {
                        if $0 != nil {
                            self.post.onNext($0)
                            self.liked.onNext(true)
                            val!.cell.postModel.accept($0)
                        } else {
                            self.liked.onNext(false)
                        }
                        
                    }.disposed(by: self.activityDisposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        commentButtonTapped
            .bind {
                if $0.content == "" {
                    self.replyAdded.onNext(false)
                } else {
                    self.activityDisposeBag = DisposeBag()
                    ReplyServices.writeReply(reply: $0).bind {
                        if $0 != nil {
                            self.replies.onNext($0)
                            self.replyAdded.onNext(true)
                        }
                    }.disposed(by: self.activityDisposeBag)
                }
            }
            .disposed(by: disposeBag)
    }
}
