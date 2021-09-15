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
        
        // view model
        let viewModel = NewPostViewModel(
            input: (
                titleText: newPostView.titleTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                contentText: newPostView.contentTextView
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                createButtonTap: self.navigationItem.rightBarButtonItem!.rx.tap.asSignal())
        )
        
        // bind results
        viewModel.postCreated
            .debug()
            .subscribe(onNext: {
                if $0 {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
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
