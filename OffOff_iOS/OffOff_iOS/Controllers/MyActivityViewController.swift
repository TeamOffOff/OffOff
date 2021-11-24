//
//  MyActivityViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/23.
//

import UIKit

import RxSwift
import RxCocoa

class MyActivityViewController: UIViewController {

    let customView = MyActivityView()
    var viewModel: MyActivityViewModel!
    
    var disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = MyActivityViewModel(
            alertListTapped: customView.alertListButton.rx.tap,
            myPostTapped: customView.myPostListButton.rx.tap,
            myReplyTapped: customView.myReplyListButton.rx.tap,
            scrapTapped: customView.scrapListButton.rx.tap,
            messageTapped: customView.messageListButton.rx.tap)
        
        customView.alertListButton.rx.tap
            .bind { _ in
                print(#fileID, #function, #line, "")
            }
            .disposed(by: disposeBag)
    }

}
