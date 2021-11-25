//
//  PostSearchViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/13.
//

import Foundation

import RxSwift
import RxCocoa

class PostSearchViewModel {
    
    var searchedList = Observable<[PostModel]>.just([])
    
    var postList = BehaviorRelay<[PostModel]>(value: [])
    var isSearching = Observable.just(false)
    
    var standardId: String? = nil
    
    var disposeBag = DisposeBag()
    
    init(
        boardType: String,
        searchingText: Observable<String>
    ) {
        searchedList = searchingText
            .skip(1)
            .flatMap { [weak self] key -> Observable<[PostModel]> in
                guard let self = self else { return Observable.just([]) }
                if key == "" {
                    return Observable.just([])
                }
                return SearchServices.searchPosts(in: boardType, key: key, standardId: self.standardId)
                    .filter { $0 != nil }
                    .map {
                        $0!.postList
                    }
            }
        
        // TODO 계속 검색
        
    }
}
