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
    
    var deleteButtonTapped = BehaviorSubject<UserInfo?>(value: nil)
    var liked = BehaviorSubject<ActivityResultType>(value: ActivityResultType.error)
    var bookmarked = BehaviorSubject<ActivityResultType>(value: ActivityResultType.error)
    var reported = BehaviorSubject<ActivityResultType>(value: ActivityResultType.error)
    var replyAdded = BehaviorSubject<Bool>(value: false)
    
    var isSubReplyInputting = BehaviorSubject<Reply?>(value: nil)
    
    var disposeBag = DisposeBag()
    var activityDisposeBag = DisposeBag()
    
    var reportButtonTapped = BehaviorSubject<Bool>(value: false)
//    var reported: Observable<Bool>
    
    let refreshing = BehaviorSubject<Void>(value: ())
    
    init(contentId: String, boardType: String, likeButtonTapped: Observable<PostLikeModel?>, replyButtonTapped: Observable<WritingReply>, bookmarkButtonTapped: Observable<(String, String)>) {
        ReplyServices.fetchReplies(of: contentId, in: boardType)
            .bind { [weak self] in
                var replies = [Reply]()
                $0.forEach {
                    replies.append($0)
                    if $0.childrenReplies != nil &&  $0.childrenReplies!.count > 0 {
                        replies.append(contentsOf: $0.childrenReplies!)
                    }
                }
                self?.replies.onNext(replies)
            }.disposed(by: disposeBag)
        
        PostServices.fetchPost(content_id: contentId, board_type: boardType)
            .bind { [weak self] in self?.post.onNext($0) }
            .disposed(by: disposeBag)
        
        
        postDeleted = Observable.combineLatest(post, deleteButtonTapped)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .filter { $0.1 != nil && $0.0 != nil }
            .flatMap { val -> Observable<Bool> in
                if val.0!.author!._id == val.1!._id {
                    return PostServices.deletePost(post: DeletingPost(_id: val.0!._id!, boardType: val.0!.boardType, author: val.0!.author!._id!))
                } else {
                    return Observable.just(false)
                }
            }
        
//        likeButtonTapped
//            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
//            .flatMap { val -> Observable<(PostModel?, PostLikeModel?)> in
//                if val != nil {
//                    let post = PostActivity(boardType: boardType, _id: val!.id, activity: "likes")
//                    return PostServices.likePost(post: post).flatMap { Observable.just(($0, val)) }
//                } else {
//                    return Observable.just((nil, nil))
//                }
//            }
//            .bind { [weak self] (postModel, likeModel) in
//                if postModel != nil {
//                    self?.post.onNext(postModel)
//                    self?.liked.onNext(true)
//                    likeModel!.cell.postModel.accept(postModel)
//                } else {
//                    self?.liked.onNext(false)
//                }
//            }
//            .disposed(by: disposeBag)
        
        likeButtonTapped
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { val -> Observable<ActivityResultType> in
                if val != nil {
                    let post = PostActivity(boardType: boardType, _id: val!.id, activity: "likes")
                    return PostServices.likePost(post: post)
                } else {
                    return Observable.just(ActivityResultType.error)
                }
            }
            .bind { [weak self] type in
                self?.liked.onNext(type)
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
            .withUnretained(self)
            .bind { (owner, replyList) in
                owner.isSubReplyInputting.onNext(nil)
                if replyList != nil {
                    var replies = [Reply]()
                    replyList!.forEach {
                        replies.append($0)
                        if $0.childrenReplies != nil &&  $0.childrenReplies!.count > 0 {
                            replies.append(contentsOf: $0.childrenReplies!)
                        }
                    }
                    owner.replies.onNext(replies)
                    owner.replyAdded.onNext(true)
                }
            }
            .disposed(by: disposeBag)
        
        bookmarkButtonTapped
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { val -> Observable<ActivityResultType> in
                let post = PostActivity(boardType: val.1, _id: val.0, activity: "bookmarks")
                return PostServices.likePost(post: post)
            }
            .bind { [weak self] type in
                    self?.bookmarked.onNext(type)
            }
            .disposed(by: disposeBag)
        
        reportButtonTapped
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .filter { $0 }
            .flatMap { val -> Observable<ActivityResultType> in
                let post = PostActivity(boardType: boardType, _id: contentId, activity: "reports")
                return PostServices.likePost(post: post)
            }
            .bind { [weak self] type in
                    self?.reported.onNext(type)
            }
            .disposed(by: disposeBag)
    }
    
    func reloadPost(contentId: String, boardType: String) {
        PostServices.fetchPost(content_id: contentId, board_type: boardType)
            .do { [weak self] _ in self?.refreshing.onNext(()) }
            .bind { [weak self] in self?.post.onNext($0) }
            .disposed(by: disposeBag)
    }
    
    func reloadReplies(contentId: String, boardType: String) {
        ReplyServices.fetchReplies(of: contentId, in: boardType)
            .bind { [weak self] in
                var replies = [Reply]()
                $0.forEach {
                    replies.append($0)
                    if $0.childrenReplies != nil &&  $0.childrenReplies!.count > 0 {
                        replies.append(contentsOf: $0.childrenReplies!)
                    }
                }
                self?.replies.onNext(replies)
            }.disposed(by: disposeBag)
    }
}

struct PostLikeModel {
    var id: String
    var type: String
    var cell: PostPreviewCell
}
