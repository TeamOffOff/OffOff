//
//  BoardServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/01.
//

import Foundation
import Moya
import RxMoya
import RxSwift

public class BoardServices {
    static let provider = MoyaProvider<BoardAPI>()
    
    static func makeBoard(completion: @escaping () -> Void) {
        
    }
    
    static func deleteBoard(completion: @escaping () -> Void) {
        
    }
    
    static func fetchBoardList() -> Observable<BoardList?> {
        BoardServices.provider
            .rx.request(.getBoardList)
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let boards = try JSONDecoder().decode(BoardList.self, from: $0.data)
                    return boards
                }
                return nil
            }
            .catchErrorJustReturn(nil)
    }
    
    static func fetchPostList(board_type: String) -> Observable<PostList?> {
        BoardServices.provider
            .rx.request(.getPostList(board_type, nil))
            .asObservable()
            .map {
                print($0)
                if $0.statusCode == 200 {
                    do {
                        let postList = try JSONDecoder().decode(PostList.self, from: $0.data)
                        return postList
                    } catch {
                        print(error)
                    }
                    
                    
                }
                return nil
            }
            .catchErrorJustReturn(nil)
    }
}