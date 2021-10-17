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
    let isTitleConfirmed = BehaviorSubject<Bool>(value: false)
    let isContentConfiremd = BehaviorSubject<Bool>(value: false)
    var postCreated = Observable<PostModel?>.just(nil)
    
    init(
        input: (
            titleText: Driver<String>,
            contentText: Driver<String>,
            createButtonTap: Signal<()>,
            post: Observable<PostModel?>
        )
    ) {
        // outputs
        let titleAndContent = Driver.combineLatest(input.titleText, input.contentText, input.post.asDriver(onErrorJustReturn: nil)) { (title: $0, content: $1, post: $2) }
        
        postCreated = input.createButtonTap.withLatestFrom(titleAndContent)
            .asObservable()
            .flatMap { val -> Observable<PostModel?> in
                if val.title == "" {
                    self.isTitleConfirmed.onNext(false)
                    return Observable.just(nil)
                }
                if val.content == "" {
                    self.isContentConfiremd.onNext(false)
                    return Observable.just(nil)
                }
                
                if Constants.currentBoard != nil && Constants.loginUser != nil {
                    var post = WritingPost(boardType: Constants.currentBoard!, author: Constants.loginUser!._id, title: val.title, content: val.content)
                    
                    if val.post != nil {
                        post._id = val.post!._id
                        post.author = val.post!.author._id!
                        return PostServices.modifyPost(post: post)
                    }
                    
                    return PostServices.createPost(post: post)
                }
                return Observable.just(nil)
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
