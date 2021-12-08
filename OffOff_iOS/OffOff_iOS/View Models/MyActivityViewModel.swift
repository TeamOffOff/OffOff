//
//  MyActivityViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/23.
//

import Foundation

import RxSwift
import RxCocoa

class MyActivityViewModel {
    
    var viewControllerToOpen: Observable<UIViewController>
    
    init(
        alertListTapped: ControlEvent<()>,
        myPostTapped: Observable<String>,
        myReplyTapped: Observable<String>,
        scrapTapped: Observable<String>,
        messageTapped: ControlEvent<()>
    ) {
        viewControllerToOpen = Observable.merge(myPostTapped, myReplyTapped, scrapTapped)
            .map {
                let vc = PostListViewController()
                vc.boardType = $0
                vc.boardName = $0
                return vc
            }
    }
}
