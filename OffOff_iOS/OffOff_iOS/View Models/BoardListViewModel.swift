//
//  BoardListViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/02.
//

import Foundation
import RxSwift
import RxCocoa

class BoardListViewModel {
    // outputs
    let boardLists: Observable<[Board]>
    var isSearching = BehaviorSubject<Bool>(value: false)
    var searchResults = BehaviorRelay<[PostModel]>(value: [])
    var reloadTrigger = PublishSubject<Bool>()
    
    var disposeBag = DisposeBag()
    
    var lastPostId: String? = nil
    var lastKey: String? = nil
    
    init(searchText: Observable<String>) {
        boardLists = BoardServices.fetchBoardList()
            .map {
                return $0?.boardList ?? []
            }
        
        searchText
            .skip(1)
            .debounce(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .filter { [weak self] key in
                let textIsEmpty = (key == "")
                if textIsEmpty {
                    self?.searchResults.accept([])
                    self?.lastPostId = nil
                    self?.lastKey = nil
                    self?.isSearching.onNext(false)
                }
                return !textIsEmpty
            }
            .flatMap { [weak self] key -> Observable<PostList> in
                self?.lastKey = key
                self?.isSearching.onNext(true)
                return SearchServices.totalSearch(key: key, lastPostId: nil)
                    .filter { $0 != nil }
                    .map { $0! }
            }
            .bind { [weak self] in
                self?.lastPostId = $0.lastPostId
                self?.searchResults.accept($0.postList)
            }
            .disposed(by: disposeBag)
        
        reloadTrigger
            .filter { [weak self] _ in self?.lastPostId != nil && self?.lastKey != nil }
            .flatMap { [weak self] _ in
                SearchServices.totalSearch(key: (self?.lastKey)!, lastPostId: self?.lastPostId!)
                    .filter { $0 != nil }
                    .map { $0! }
            }
            .withUnretained(self)
            .bind { (owner, postList) in
                if postList.postList.isEmpty {
                    return
                }
                var list: [PostModel] = []
                list = postList.postList + owner.searchResults.value
                owner.searchResults.accept(list)
            }
            .disposed(by: disposeBag)
        
    }
}
