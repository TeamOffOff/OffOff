//
//  NewPostViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/09.
//

import Foundation
import RxSwift
import RxCocoa

class NewPostViewModel {
    let postCreation: Driver<Bool>
    let isTitleConfirmed: Driver<Bool>
    let isContentConfiremd: Driver<Bool>
    let postCreated: Observable<Bool>
    let newPost: PublishSubject<PostModel?> = PublishSubject<PostModel?>()
    
    init(
        input: (
            titleText: Driver<String>,
            contentText: Driver<String>,
            createButtonTap: Signal<()>
        )
    ) {
        // outputs
        
        isTitleConfirmed = input.titleText.map { $0 != "" }
        isContentConfiremd = input.contentText.map { $0 != "" }
        
        let titleAndContent = Driver.combineLatest(input.titleText, input.contentText) { (title: $0, content: $1) }
        
        postCreation = input.createButtonTap.withLatestFrom(titleAndContent)
            .flatMap { pair in
                return Driver.just(pair.title != "" && pair.content != "")
            }
        
        var postModel: WritingPost?
        postCreated = postCreation.asObservable().withLatestFrom(titleAndContent.asObservable()) {
            print(#fileID, #function, #line, "")
            if $0 {
                print($1)
                
                // TODO: 현재 로그인하고 있는 회원정보, 현재 접속하고 있는 게시판 정보를 넣어서 새로운 포스트 작성
                if Constants.currentBoard != nil && Constants.loginUser != nil {
                    postModel = WritingPost(boardType: Constants.currentBoard!, author: Constants.loginUser!.subInformation.nickname, title: $1.title, content: $1.content)
                }
            }
        }
        .debug()
        .flatMap { _ -> Observable<Bool> in
            if postModel != nil {
                return PostServices.createPost(post: postModel!).map { $0 }
            }
            return Observable.just(false)
        }
    }
}

struct WritingPost: Codable {
    var _id: String? = nil
    var boardType: String
    var author: String
    var title: String
    var content: String
    var image: String? = nil
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(boardType, forKey: .boardType)
        try container.encode(author, forKey: .author)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(image, forKey: .image)
    }
}
