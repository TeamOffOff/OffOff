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
        customView.greetingLabel.text = "\(Constants.loginUser!.subInformation.nickname) 님의 활동"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = MyActivityViewModel(
            alertListTapped: customView.alertListButton.rx.tap,
            myPostTapped: customView.myPostListButton.rx.tap.asObservable().map { "내가 쓴 글" },
            myReplyTapped: customView.myReplyListButton.rx.tap.asObservable().map { "댓글 단 글" },
            scrapTapped: customView.scrapListButton.rx.tap.asObservable().map { "스크랩한 글" },
            messageTapped: customView.messageListButton.rx.tap)
        
        customView.alertListButton.rx.tap
            .bind { _ in
                print(#fileID, #function, #line, "")
            }
            .disposed(by: disposeBag)
        
//        customView.myPostListButton.rx.tap
//            .bind { [weak self] in
//                let vc = PostListViewController()
//                vc.boardType = "내가 쓴 글"
//                vc.boardName = "내가 쓴 글"
//                let nav = UINavigationController(rootViewController: vc)
//                nav.modalPresentationStyle = .fullScreen
//                nav.navigationBar.setAppearance()
//                self?.present(nav, animated: true, completion: nil)
//            }
//            .disposed(by: disposeBag)
//
//        customView.myReplyListButton.rx.tap
//            .bind { [weak self] in
//                let vc = PostListViewController()
//                vc.boardType = "댓글 단 글"
//                vc.boardName = "댓글 단 글"
//                let nav = UINavigationController(rootViewController: vc)
//                nav.modalPresentationStyle = .fullScreen
//                nav.navigationBar.setAppearance()
//                self?.present(nav, animated: true, completion: nil)
//            }
//            .disposed(by: disposeBag)
//
//        customView.scrapListButton.rx.tap
//            .bind { [weak self] in
//                let vc = PostListViewController()
//                vc.boardType = "스크랩한 글"
//                vc.boardName = "스크랩한 글"
//                let nav = UINavigationController(rootViewController: vc)
//                nav.modalPresentationStyle = .fullScreen
//                nav.navigationBar.setAppearance()
//                self?.present(nav, animated: true, completion: nil)
//            }
//            .disposed(by: disposeBag)
        
        viewModel.viewControllerToOpen
            .bind { [weak self] in
                let nav = UINavigationController(rootViewController: $0)
                nav.modalPresentationStyle = .fullScreen
                nav.navigationBar.setAppearance()
                self?.present(nav, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }

}
