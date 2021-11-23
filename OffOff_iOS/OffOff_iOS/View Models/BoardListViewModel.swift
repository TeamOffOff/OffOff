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
    var isSearching: Observable<Bool>
    var searchResults = Observable<[PostModel]>.just([])
    
    init(searchText: Observable<String?>) {
        boardLists = BoardServices.fetchBoardList()
            .map {
                return $0?.boardList ?? []
            }
        
        isSearching = searchText.map { $0 != "" && $0 != nil }
        
        searchResults = searchText
            .skip(1)
            .flatMap { key -> Observable<[PostModel]> in
                if key == "" || key == nil {
                    return Observable.just([])
                }
                return SearchServices.totalSearch(key: key!, lastPostId: nil)
                    .filter { $0 != nil }
                    .map {
                        $0!.postList
                    }
            }
    }
}
