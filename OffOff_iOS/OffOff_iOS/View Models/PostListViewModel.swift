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
    
    let reloadTrigger = PublishSubject<Void>()
    let refreshing = BehaviorSubject<Void>(value: ())
    
    var lastContentId: String? = nil
    
    init(boardType: String) {
        self.boardType = boardType
        fetchPostList(boardType: self.boardType)
        
        self.reloadTrigger
            .debug()
            .flatMapLatest { _ -> Observable<PostList?> in
                self.refreshing.onNext(())
                return BoardServices.fetchPostList(board_type: boardType, lastContentID: self.lastContentId)
            }
            .filter { $0 != nil }
            .map { result -> [PostModel] in
                self.lastContentId = result?.lastPostId
                return result?.postList ?? []
            }
            .bind {
                var list = self.postList.value
                list.append(contentsOf: $0)
                self.postList.accept(list)
                print(self.postList.value)
            }
            .disposed(by: disposeBag)
    }
    
    public func fetchPostList(boardType: String) {
        _ = BoardServices.fetchPostList(board_type: boardType).map {
            self.lastContentId = $0?.lastPostId
            return $0?.postList ?? []
        }.bind(to: self.postList)
    }
}
