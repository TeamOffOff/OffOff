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
        
        var postModel: PostModel?
        postCreated = postCreation.asObservable().withLatestFrom(titleAndContent.asObservable()) {
            print(#fileID, #function, #line, "")
            if $0 {
                print($1)
                
                // TODO: 현재 로그인하고 있는 회원정보, 현재 접속하고 있는 게시판 정보를 넣어서 새로운 포스트 작성
                postModel = PostModel(_id: nil, boardType: "free", author: Author(_id: "admin", nickname: "admin", type: "admin", profileImage: nil), date: "2021-08-11", title: $1.0, content: $1.1,image: nil, likes: 0, viewCount: 0, reportCount: 0, replyCount: 0)
            }
        }
        .debug()
        .flatMap {
            PostServices.createPost(post: postModel!).map { $0 }
        }
    }
}
