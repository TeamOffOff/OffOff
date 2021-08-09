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
                Driver.just(pair.title != "" && pair.content != "")
            }
        
        postCreated = postCreation.asObservable().map {
            $0
        }
    }
}
