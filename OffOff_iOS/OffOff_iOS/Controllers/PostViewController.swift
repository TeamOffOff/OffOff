//
//  PostViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/06.
//

import UIKit
import RxSwift

class PostViewController: UIViewController {
    var postView = PostView(frame: .zero)
    var postInfo: (id: String, type: String)?
    let disposeBag = DisposeBag()
    
    var commentContainer = UIView().then {
        $0.backgroundColor = .white
        $0.makeBorder(color: UIColor.mainColor.cgColor, cornerRadius: 12)
    }
    var commentTextView = UITextView().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.tintColor = .mainColor
//        $0.backgroundColor = .white
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
        
        // view model
        let viewModel = PostViewModel(contentId: postInfo?.id ?? "", boardType: postInfo?.type ?? "")
        
        // bind result
        viewModel.post
            .bind {
                self.postView.titleLabel.text = $0?.title
                self.postView.authorLabel.text = $0?.author.nickname
                self.postView.contentTextView.text = $0?.content
                self.postView.dateLabel.text = $0?.date
                self.postView.profileImageView.image = UIImage(systemName: "person.fil")
                self.postView.likeButton.setTitle("\($0?.likes ?? 0)", for: .normal)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardNotifications()
    }
}

// MARK: - TextView가 키보드 위로 이동하도록 하는 함수
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
        }
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification) {
        self.commentContainer.snp.remakeConstraints {
            $0.right.left.equalToSuperview().inset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
    }
}

extension PostViewController: UITextViewDelegate {
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSAttributedString.Key.font: font],
            context: nil).size
    }

    // Text가 4줄 이상이면, 스크롤이 되게하고, 텍스트뷰가 커지지 않도록
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var textWidth = textView.frame.inset(by: textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding

        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight

        if numberOfLines >= 4.0 {
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
        
        return true
    }
}
