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
    var isUploadingImage = Observable<Bool>.just(false)
    
    var isCreating = BehaviorSubject<Bool>(value: false)
    
    var uploadingImages = BehaviorRelay<[UIImage]>(value: [])
    var disposeBag = DisposeBag()
    
    init(
        input: (
            titleText: Driver<String>,
            contentText: Driver<String>,
            createButtonTap: Observable<UITapGestureRecognizer>,
            imageUploadButtonTapped: ControlEvent<()>,
            post: Observable<PostModel?>
        )
    ) {
        // outputs
        let titleAndContent = Driver.combineLatest(input.titleText, input.contentText, input.post.asDriver(onErrorJustReturn: nil), uploadingImages.asDriver()) { (title: $0, content: $1, post: $2, images: $3) }
        
        postCreated = input.createButtonTap.withLatestFrom(titleAndContent)
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .withUnretained(self)
            .do { (owner, _) in
                owner.isCreating.onNext(true)
            }
            .flatMap { (owner, val) -> Observable<PostModel?> in
                if val.title == "" {
                    owner.isTitleConfirmed.onNext(false)
                    return Observable.just(nil)
                }
                if val.content == "" {
                    owner.isContentConfiremd.onNext(false)
                    return Observable.just(nil)
                }
                
                if Constants.currentBoard != nil && Constants.loginUser != nil {
                    var post = WritingPost(boardType: Constants.currentBoard!, author: Constants.loginUser!._id, title: val.title, content: val.content)
                    post.image = val.images.map { ImageObject(body: $0.toBase64String()) }
                    if val.post != nil {
                        post._id = val.post!._id
                        post.author = val.post!.author._id!
                        return PostServices.modifyPost(post: post)
                    }
                    
                    return PostServices.createPost(post: post)
                }
                return Observable.just(nil)
            }
        
        isUploadingImage = input.imageUploadButtonTapped.asObservable().map { true }
    }
}

struct WritingPost: Codable {
    var _id: String? = nil
    var boardType: String
    var author: String
    var title: String
    var content: String
    var image: [ImageObject] = []
    
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
