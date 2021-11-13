//
//  NewPostViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture

class NewPostViewController: UIViewController {
    let disposeBag = DisposeBag()
    let newPostView = NewPostView()
    
    var postToModify: PostModel? = nil
    
    override func loadView() {
        self.view = newPostView
        self.view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "글 쓰기"
        
        let saveButton = UILabel(frame: CGRect(x: 0, y: 0, width: 47.adjustedWidth, height: 27.adjustedHeight)).then {
            $0.backgroundColor = .g1
            $0.text = "완료"
            $0.font = .defaultFont(size: 14, bold: true)
            $0.textColor = .g4
            $0.textAlignment = .center
            $0.setCornerRadius(8.04.adjustedHeight)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        var alert = UIAlertController(title: "제목을 입력해주세요.", message: nil, preferredStyle: .alert)
        
        self.navigationItem.rightBarButtonItem!.rx.tap
            .bind { _ in
                print(#fileID, #function, #line, "")
            }.disposed(by: disposeBag)
        
        // 수정일 때 세팅
        setModifyingMode(postToModify != nil)
        
        // view model
        let viewModel = NewPostViewModel(
            input: (
                titleText: newPostView.titleTextField
                    .rx.text
                    .orEmpty
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                contentText: newPostView.contentTextView
                    .rx.text
                    .orEmpty
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                createButtonTap: saveButton.rx.tapGesture()
                    .when(.recognized),
                post: Observable.just(postToModify)
            )
        )
        
        // 텍스트 뷰 크기 제한
        self.newPostView.contentTextView
            .rx.text
            .bind { _ in
                let needToScrolling = self.newPostView.contentTextView.frame.height > Constants.SCREEN_SIZE.height / 3
                
//                if needToScrolling {
//                    self.newPostView.contentTextView.snp.remakeConstraints {
//                        $0.top.equalTo(self.newPostView.lineView.snp.bottom).offset(21.adjustedHeight)
//                        $0.left.right.equalToSuperview().inset(33.adjustedWidth)
//                        $0.height.equalTo(self.newPostView.contentTextView.frame.height)
//                    }
//                } else {
//                    self.newPostView.contentTextView.snp.removeConstraints()
//                    self.newPostView.contentTextView.snp.remakeConstraints {
//                        $0.top.equalTo(self.newPostView.lineView.snp.bottom).offset(21.adjustedHeight)
//                        $0.left.right.equalToSuperview().inset(33.adjustedWidth)
//                    }
//                    self.newPostView.contentTextView.sizeToFit()
//                }
                
                self.newPostView.contentTextView.isScrollEnabled = needToScrolling
            
                print(self.newPostView.contentTextView.frame.height)
            }
            .disposed(by: disposeBag)
        
        // bind results
        viewModel.isTitleConfirmed
            .skip(1)
            .filter { $0 == false }
            .do { _ in
                alert = UIAlertController(title: "제목을 입력해주세요.", message: nil, preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            }
            .delay(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .bind { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        viewModel.isContentConfiremd
            .skip(1)
            .filter { $0 == false }
            .do { _ in
                alert = UIAlertController(title: "내용을 입력해주세요.", message: nil, preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            }
            .delay(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .bind { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        viewModel.postCreated
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(onNext: {
                if self.postToModify == nil {
                    self.navigationController?.popViewController(animated: true)
                    if let frontVC = self.navigationController?.topViewController as? PostListViewController {
                        frontVC.viewModel?.fetchPostList(boardType: frontVC.boardType!)
                        print(#fileID, #function, #line, "")
                    }
                } else {
                    if let naviVC = self.presentingViewController as? UINavigationController {
                        if let postVC = naviVC.topViewController as? PostViewController {
                            postVC.postInfo = (id: $0._id!, type: $0.boardType)
                            postVC.viewModel.reloadPost(contentId: $0._id!, boardType: $0.boardType)
                        }
                    }
                    
                    self.dismiss(animated: true) 
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setModifyingMode(_ on: Bool) {
        if on {
            self.title = "글 수정"
            self.newPostView.titleTextField.text = postToModify!.title
            self.newPostView.contentTextView.text = postToModify!.content
            
            self.navigationController?.navigationBar.setAppearance()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
            self.navigationItem.leftBarButtonItem!.rx.tap
                .bind { self.dismiss(animated: true, completion: nil) }.disposed(by: disposeBag)
        }
    }
}
