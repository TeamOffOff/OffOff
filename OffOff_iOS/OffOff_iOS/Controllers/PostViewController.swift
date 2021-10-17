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
    
    var viewModel: PostViewModel!
    let disposeBag = DisposeBag()
    
    let deleteButton = UIBarButtonItem(title: "삭제", style: .plain, target: nil, action: nil)
    let editButton = UIBarButtonItem(title: "수정", style: .plain, target: nil, action: nil)
    lazy var items = [editButton, deleteButton]
    var rightButtonsDisposeBag = DisposeBag()
    
    var postCell: PostPreviewCell?
    
    var replyCellHeight = 125.0
    
    var replyContainer = UIView().then {
        $0.backgroundColor = .white
        $0.makeBorder(color: UIColor.mainColor.cgColor, cornerRadius: 12)
    }
    var replyTextView = UITextView().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.tintColor = .mainColor
        $0.autocorrectionType = .no
    }
    var replyButton = UIButton().then {
        $0.setImage(.getIcon(name: .pen, color: .mainColor, size: Constants.BUTTON_ICON_SIZE), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        view.addSubview(postView)
        view.addSubview(replyContainer)
        replyContainer.addSubview(replyTextView)
        replyContainer.addSubview(replyButton)
        self.makeView()
        
        replyTextView.delegate = self
        addKeyboardNotifications()
        
        // view model
        viewModel = PostViewModel(
            contentId: postInfo?.id ?? "",
            boardType: postInfo?.type ?? "",
            likeButtonTapped: self.postView.likeButton.rx.tap
                .map {
                    PostLikeModel(id: self.postInfo!.id, type: self.postInfo!.type, cell: self.postCell!)
                },
            replyButtonTapped: self.replyButton.rx.tap.map {
                let reply = WritingReply(boardType: self.postInfo!.type, postId: self.postInfo!.id, parentReplyId: nil, content: self.replyTextView.text ?? "")
                return reply
            }
        )
        
        self.postView.repliesTableView.rowHeight = UITableView.automaticDimension
        self.postView.repliesTableView.estimatedRowHeight = 400
        
        // bind result
        viewModel.post
            .filter { $0 != nil }
            .bind {
                self.postView.titleLabel.text = $0!.title
                self.postView.authorLabel.text = $0!.author.nickname
                self.postView.contentTextView.text = $0!.content
                self.postView.dateLabel.text = $0!.date
                self.postView.profileImageView.image = UIImage(systemName: "person.fil")
                self.postView.likeButton.setTitle("\($0!.likes.count)", for: .normal)
                if $0?.author._id == Constants.loginUser?._id {
                    print(#fileID, #function, #line, "")
                    self.setRightButtons(set: true)
                } else {
                    self.setRightButtons(set: false)
                }
                
                // TODO: 이미 좋아요 누른 게시글이면 좋아요 버튼에 표시
            }
            .disposed(by: disposeBag)
        
        viewModel.postDeleted
            .filter { $0 }
            .bind { _ in
                self.navigationController?.popViewController(animated: true)
                if let frontVC = self.navigationController?.topViewController as? PostListViewController {
                    frontVC.viewModel?.fetchPostList(boardType: frontVC.boardType!)
                    print(#fileID, #function, #line, "")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.liked
            .skip(1)
            .do {
                if $0 {
                    self.activityAlert(message: "좋아요를 했습니다.")
                } else {
                    self.activityAlert(message: "이미 좋아요한 게시글 입니다.")
                }
            }
            .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { _ in
                self.dismissAlert(animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.replies
            .filter { $0 != nil }
            .do { self.postCell?.commentLabel.label.text = "\($0!.count)"}
            .map { $0! }
            .bind(to: self.postView.repliesTableView.rx.items(cellIdentifier: RepliesTableViewCell.identifier, cellType: RepliesTableViewCell.self)) { (row, element, cell) in
                cell.boardTpye = self.postInfo?.type
                cell.reply.onNext(element)
                cell.activityAlert = self.activityAlert
                cell.dismissAlert = self.dismissAlert
                cell.presentMenuAlert = self.presentMenuAlert
                cell.replies = self.viewModel.replies
            }
            .disposed(by: disposeBag)
        
        let alert = UIAlertController(title: "댓글이 등록됐습니다.", message: nil, preferredStyle: .alert)
        viewModel.replyAdded
            .filter { $0 }
            .do {
                if $0 {
                    self.replyTextView.text = ""
                    self.replyTextView.resignFirstResponder()
                    self.present(alert, animated: true, completion: nil)
                }
            }
            .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { _ in
                alert.dismiss(animated: true, completion: nil)
                if self.postView.bounds.size.height < self.postView.contentSize.height {
                    self.postView.scrollToBottom()
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardNotifications()
    }
    
    // MARK: - Private Funcs
    private func makeView() {
        postView.snp.makeConstraints {
            $0.left.right.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Constants.SCREEN_SIZE.height / 12.5)
        }
        replyContainer.snp.makeConstraints {
            $0.right.left.equalToSuperview().inset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
        replyTextView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().inset(Constants.SCREEN_SIZE.width / 7.5)
        }
        replyButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(replyTextView)
        }
        postView.makeView()
    }
    
    private func setRightButtons(set: Bool) {
        if set {
            self.navigationItem.setRightBarButtonItems(items, animated: false)
            deleteButton.rx.tap.bind {
                self.deletingConfirmAlert()
            }.disposed(by: rightButtonsDisposeBag)
            editButton.rx.tap.asObservable().withLatestFrom(viewModel.post)
                .bind {
                    let vc = NewPostViewController()
                    vc.postToModify = $0
                    let naviVC = UINavigationController(rootViewController: vc)
                    naviVC.modalPresentationStyle = .fullScreen
                    self.present(naviVC, animated: true, completion: nil)
                }.disposed(by: rightButtonsDisposeBag)
        } else {
            self.navigationItem.setRightBarButtonItems([], animated: false)
            rightButtonsDisposeBag = DisposeBag()
        }
    }
    
    private func deletingConfirmAlert() {
        let alert = UIAlertController(title: "정말 삭제하시겠습니까??", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "예", style: .default) { _ in self.viewModel.deleteButtonTapped.onNext(Constants.loginUser) }
        let cancel = UIAlertAction(title: "취소", style: .default) { _ in alert.dismiss(animated: true, completion: nil) }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    var alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private func activityAlert(message: String) {
        alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func dismissAlert(animated: Bool = true) {
        alert.dismiss(animated: true, completion: nil)
    }
    
    var menuAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private func presentMenuAlert(alert: UIAlertController) {
        menuAlert = alert
        self.present(menuAlert, animated: true, completion: nil)
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
            self.replyContainer.snp.remakeConstraints {
                $0.right.left.equalToSuperview().inset(12)
                $0.bottom.equalTo(self.view.snp.bottom).inset(keyboardHeight)
            }
        }
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification) {
        self.replyContainer.snp.remakeConstraints {
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
