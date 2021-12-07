//
//  PostListViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

import Foundation
import UIKit.UIRefreshControl
import RxSwift
import RxCocoa

class PostListViewModel {
    let disposeBag = DisposeBag()
    
    var postList = BehaviorRelay<[PostModel]>(value: [])
    
    var boardType = ""
    
    let reloadTrigger = PublishSubject<PostListReloadingType>()
    let refreshing = BehaviorSubject<Void>(value: ())
    
    var lastPostId: String? = nil
    
    init(boardType: String) {
        self.boardType = boardType
        fetchPostList(boardType: boardType)
        
        reloadTrigger
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .withUnretained(self)
            .flatMapLatest { (owner, type) -> Observable<PostList?> in
                switch type {
                case .newer:
                    owner.refreshing.onNext(())
                    return BoardServices.fetchPostList(board_type: boardType, firstPostId: owner.postList.value.first!._id)
                case .older:
                    owner.refreshing.onNext(())
                    return BoardServices.fetchPostList(board_type: boardType, lastPostId: owner.lastPostId)
                }
            }
            .filter { $0 != nil }
            .map { $0! }
            .withUnretained(self)
            .bind { (owner, postList) in
                if postList.postList.isEmpty {
                    return
                }
                var list: [PostModel] = []
                
                if postList.lastPostId != nil {
                    owner.lastPostId = postList.lastPostId
                    list = owner.postList.value + postList.postList
                } else {
                    list = postList.postList + owner.postList.value
                }
                
                owner.postList.accept(list)
            }
            .disposed(by: disposeBag)
    }
    
    public func fetchPostList(boardType: String) {
        if let type = ActivityTypes(rawValue: boardType) {
            UserServices.getMyActivies(type: type)
                .map {
                    return $0?.postList ?? []
                }
                .bind(to: postList)
                .disposed(by: disposeBag)
        } else {
            BoardServices.fetchPostList(board_type: boardType)
                .map { [weak self] in
                    self?.lastPostId = $0?.lastPostId
                    return $0?.postList ?? []
                }
                .bind(to: postList)
                .disposed(by: disposeBag)
        }
    }
}

enum PostListReloadingType {
    case newer
    case older
}
