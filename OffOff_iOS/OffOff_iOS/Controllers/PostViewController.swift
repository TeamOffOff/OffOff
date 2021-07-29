//
//  PostViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/06.
//

import UIKit

class PostViewController: UIViewController {
    var postView = PostView(frame: .zero)
    var postBoxed: Box<PostModel>?
    var commentContainer = UIView()
    var commentTextView = UITextView().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.makeBorder(color: UIColor.gray.cgColor, width: 0.5)
    }
    
    override func loadView() {
        self.view = .init()
        self.view.backgroundColor = .white
        view.addSubview(postView)
        view.addSubview(commentContainer)
        postBoxed?.bind { _ in
            self.postView.setupView(post: self.postBoxed!.value)
        }
        commentContainer.addSubview(commentTextView)
        postView.snp.makeConstraints {
            $0.left.right.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Constants.SCREEN_SIZE.height / 10.0)
        }
        commentContainer.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(Constants.SCREEN_SIZE.height / 10.0)
            $0.width.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        commentTextView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().offset(12)
            $0.height.equalToSuperview()
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().inset(12)
        }
        postView.makeView()
    }
    
    override func viewDidLoad() {
        
    }
}
