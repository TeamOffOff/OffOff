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
    
    init() {
        boardLists = BoardServices.fetchBoardList()
            .map {
                return $0?.board ?? []
                
            }
    }
}
