//
//  BoardViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/02.
//

import Foundation
import Moya

class BoardViewModel {
    let boardList: Box<BoardList?> = Box(nil)
    
    init() {
        self.fetchBoardList()
    }
    
    var count: Int {
        return boardList.value?.board.count ?? 0
    }
    
    func getBoard(of index: Int) -> Board? {
        return boardList.value?.board[index]
    }
    
    func fetchBoardList() {
        BoardServices.fetchBoardList { (boardList) in
            self.boardList.value = boardList
        }
    }
}
