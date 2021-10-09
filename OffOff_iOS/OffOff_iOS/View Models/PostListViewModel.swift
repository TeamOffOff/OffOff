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
    let refreshing = BehaviorSubject<Bool>(value: false)
    
    init(boardType: String) {
        self.boardType = boardType
        fetchPostList(boardType: self.boardType)
        
        self.reloadTrigger
            .debug()
            .flatMapLatest { _ in
                BoardServices.fetchPostList(board_type: boardType)
            }
            .map { $0?.postList ?? [] }
            .bind(to: self.postList)
            .disposed(by: disposeBag)
    }
    
    public func fetchPostList(boardType: String) {
        _ = BoardServices.fetchPostList(board_type: boardType).map { $0?.postList ?? [] }.bind(to: self.postList)
    }
}
