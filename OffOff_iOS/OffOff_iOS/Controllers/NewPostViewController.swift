//
//  NewPostViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import UIKit
import RxCocoa
import RxSwift

class NewPostViewController: UIViewController {
    let disposeBag = DisposeBag()
    let newPostView = NewPostView()
    
    var postToModify: PostModel? = nil
    
    override func loadView() {
        self.view = .init()
        self.view.backgroundColor = .white
        view.addSubview(newPostView)
        newPostView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges).inset(8)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "글 쓰기"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        
        var alert = UIAlertController(title: "제목을 입력해주세요.", message: nil, preferredStyle: .alert)
        
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
                createButtonTap: self.navigationItem.rightBarButtonItem!.rx.tap.asSignal(),
                post: Observable.just(postToModify)
            )
        )
        
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

class NewPostView: UIStackView {
    var titleTextField = UITextField().then {
        $0.placeholder = "제목"
        $0.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
    }
    var contentTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 18.0)
        $0.backgroundColor = .lightGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.distribution = .fill
        self.spacing = 8
        self.addArrangedSubview(titleTextField)
        self.addArrangedSubview(contentTextView)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
