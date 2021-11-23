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
        fetchPostList(boardType: self.boardType)
        
        self.reloadTrigger
            .debug()
            .flatMapLatest { type -> Observable<PostList?> in
                switch type {
                case .newer:
                    self.refreshing.onNext(())
                    return BoardServices.fetchPostList(board_type: boardType, firstPostId: self.postList.value.first!._id)
                case .older:
                    self.refreshing.onNext(())
                    return BoardServices.fetchPostList(board_type: boardType, lastPostId: self.lastPostId)
                }
            }
            .filter { $0 != nil }
            .bind {
                var list: [PostModel] = []
                
                if $0?.lastPostId != nil {
                    self.lastPostId = $0?.lastPostId
                    list = self.postList.value + ($0?.postList ?? [])
                } else {
                    list = ($0?.postList ?? []) + self.postList.value
                }
                
                self.postList.accept(list)
            }
            .disposed(by: disposeBag)
    }
    
    public func fetchPostList(boardType: String) {
        _ = BoardServices.fetchPostList(board_type: boardType).map {
            self.lastPostId = $0?.lastPostId
            return $0?.postList ?? []
        }.bind(to: self.postList)
    }
}

enum PostListReloadingType {
    case newer
    case older
}
