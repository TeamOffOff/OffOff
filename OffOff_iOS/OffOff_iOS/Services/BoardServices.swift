//
//  BoardServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/01.
//

import Foundation
import Moya

public class BoardServices {
    static let provider = MoyaProvider<BoardAPI>()
    
    static func makeBoard(completion: @escaping () -> Void) {
        
    }
    
    static func deleteBoard(completion: @escaping () -> Void) {
        
    }
    
    static func fetchBoardList(completion: @escaping (_ boardList: BoardList) -> Void) {
        BoardServices.provider.request(.getBoardList) { (result) in
            switch result {
            case let .success(response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let decoder = JSONDecoder()
                    let boardList = try filteredResponse.map(BoardList.self, using: decoder)
                    completion(boardList)
                } catch let error {
                    print(error.localizedDescription)
                }
            case let .failure(error):
                print("request failed: \(error.errorDescription)")
            }
        }
    }
    
    static func fetchPostList(boardType: String, lastContentID: String?, completion: @escaping (_ postList: PostList) -> Void) {
        BoardServices.provider.request(.getPostList(boardType, lastContentID)) { (result) in
            switch result {
            case let .success(response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let decoder = JSONDecoder()
                    let postList = try filteredResponse.map(PostList.self, using: decoder)
                    completion(postList)
                } catch let error {
                    print(error.localizedDescription)
                }
            case let .failure(error):
                print("request failed: \(error.errorDescription)")
            }
        }
    }
}
