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
    var commentContainer = UIView().then {
        $0.backgroundColor = .systemGray
    }
    var commentTextView = UITextView().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        
        $0.autocorrectionType = .no
        
    }
    var commentButton = UIButton().then {
        $0.setImage(.getIcon(name: .pen, color: .mainColor, size: Constants.BUTTON_ICON_SIZE), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    override func loadView() {
        self.view = .init()
        self.view.backgroundColor = .white
        view.addSubview(postView)
        view.addSubview(commentContainer)
        commentContainer.addSubview(commentTextView)
        commentContainer.addSubview(commentButton)
        
        postBoxed?.bind { _ in
            self.postView.setupView(post: self.postBoxed!.value)
        }
        postView.snp.makeConstraints {
            $0.left.right.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Constants.SCREEN_SIZE.height / 12.5)
        }
        commentContainer.snp.makeConstraints {
            $0.right.left.equalToSuperview().inset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
        commentTextView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().inset(Constants.SCREEN_SIZE.width / 7.5)
        }
        commentButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(commentTextView)
        }
        postView.makeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        addKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardNotifications()
    }
}

extension PostViewController {
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ noti: NSNotification) {
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.commentContainer.snp.remakeConstraints {
                $0.right.left.equalToSuperview().inset(12)
                $0.bottom.equalTo(self.view.snp.bottom).inset(keyboardHeight)
            }
//            self.commentContainer.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification) {
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            self.commentContainer.frame.origin.y += keyboardHeight
            self.commentContainer.snp.remakeConstraints {
                $0.right.left.equalToSuperview().inset(12)
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
            }
        }
    }
}

extension PostViewController: UITextViewDelegate {
    
}
