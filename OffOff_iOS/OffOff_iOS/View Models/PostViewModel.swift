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
    
    var isSubReplyInputting = BehaviorSubject<Reply?>(value: nil)
    
    var disposeBag = DisposeBag()
    var activityDisposeBag = DisposeBag()
    
    init(contentId: String, boardType: String, likeButtonTapped: Observable<PostLikeModel?>, replyButtonTapped: Observable<WritingReply>) {
        ReplyServices.fetchReplies(of: contentId, in: boardType)
            .bind {
                var replies = [Reply]()
                $0.forEach {
                    replies.append($0)
                    if $0.childrenReplies != nil &&  $0.childrenReplies!.count > 0 {
                        replies.append(contentsOf: $0.childrenReplies!)
                    }
                }
                self.replies.onNext(replies)
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
        
        var cell: PostPreviewCell?
        likeButtonTapped
            .filter { $0 != nil }
            .do { cell = $0!.cell }
            .flatMap { val -> Observable<PostModel?> in
                let post = PostActivity(boardType: boardType, _id: val!.id, activity: "likes")
                self.activityDisposeBag = DisposeBag()
                return PostServices.likePost(post: post)
            }
            .bind {
                if $0 != nil {
                    self.post.onNext($0)
                    self.liked.onNext(true)
                    cell!.postModel.accept($0)
                } else {
                    self.liked.onNext(false)
                }
            }
            .disposed(by: disposeBag)
        
        replyButtonTapped
            .filter { $0.content != "" }
            .withLatestFrom(isSubReplyInputting) { WritingReply(_id: nil, boardType: $0.boardType, postId: $0.postId, parentReplyId: ($1 != nil) ? $1?._id : nil, content: $0.content) }
            .flatMap { reply -> Observable<[Reply]?> in
                if reply.parentReplyId != nil {
                    var subReply = reply
                    subReply._id = "\(reply.parentReplyId!)_\(Date().toString("yyyy.MM.dd.HH.mm.ss.SSS"))"
                    return SubReplyServices.writeSubReply(writingSubReply: subReply)
                } else {
                    return ReplyServices.writeReply(reply: reply)
                }
            }
            .bind {
                self.isSubReplyInputting.onNext(nil)
                if $0 != nil {
                    var replies = [Reply]()
                    $0!.forEach {
                        replies.append($0)
                        if $0.childrenReplies != nil &&  $0.childrenReplies!.count > 0 {
                            replies.append(contentsOf: $0.childrenReplies!)
                        }
                    }
                    self.replies.onNext(replies)
                    self.replyAdded.onNext(true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func reloadPost(contentId: String, boardType: String) {
        PostServices.fetchPost(content_id: contentId, board_type: boardType)
            .bind {
                self.post.onNext($0)
            }.disposed(by: disposeBag)
    }
}

struct PostLikeModel {
    var id: String
    var type: String
    var cell: PostPreviewCell
}
