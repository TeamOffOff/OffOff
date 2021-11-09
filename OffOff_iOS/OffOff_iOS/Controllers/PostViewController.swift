//
//  PostViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/06.
//

import UIKit

import RxSwift
import RxKeyboard
import RxGesture

class PostViewController: UIViewController {
    let postView = PostView()
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
        $0.textContentType = .none
    }
    var replyButton = UIButton().then {
        $0.setImage(.getIcon(name: .pen, color: .mainColor, size: Constants.BUTTON_ICON_SIZE), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(postView)
        self.view.addSubview(replyContainer)
        replyContainer.addSubview(replyTextView)
        replyContainer.addSubview(replyButton)
        self.makeView()
        
        replyTextView.delegate = self
        
        self.postView.repliesTableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.postView.repliesTableView.rowHeight = UITableView.automaticDimension
        self.postView.repliesTableView.estimatedRowHeight = 400
        
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

        // bind result
        viewModel.post
            .filter { $0 != nil }
            .bind {
                print(#fileID, #function, #line, $0?._id)
                self.postView.titleLabel.text = $0!.title
                self.postView.authorLabel.text = $0!.author.nickname
                self.postView.contentTextView.text = $0!.content
                self.postView.dateLabel.text = $0!.date
                self.postView.profileImageView.image = .DefaultPostProfileImage
//                self.postView.likeButton.setTitle("\($0!.likes.count)", for: .normal)
                if $0?.author._id == Constants.loginUser?._id {
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
            .bind(to: self.postView.repliesTableView.rx.items) { (tv, row, item) -> UITableViewCell in
                if item.parentReplyId != nil {
                    let cell = tv.dequeueReusableCell(withIdentifier: ChildrenRepliesTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! ChildrenRepliesTableViewCell
                    
                    cell.boardTpye = self.postInfo?.type
                    cell.reply.onNext(item)
                    cell.activityAlert = self.activityAlert
                    cell.dismissAlert = self.dismissAlert
                    cell.presentMenuAlert = self.presentMenuAlert
                    cell.replies = self.viewModel.replies
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: RepliesTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! RepliesTableViewCell
                    cell.isSubReplyInputting = self.viewModel.isSubReplyInputting
                    cell.boardTpye = self.postInfo?.type
                    cell.reply.onNext(item)
                    cell.activityAlert = self.activityAlert
                    cell.dismissAlert = self.dismissAlert
                    cell.presentMenuAlert = self.presentMenuAlert
                    cell.replies = self.viewModel.replies
                    cell.bindData()
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isSubReplyInputting
            .bind {
                if $0 != nil {
                    self.replyTextView.becomeFirstResponder()
                } else {
                    self.replyTextView.endEditing(true)
                }
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
        
//        self.postView.makeView()
        
        // MARK: 댓글 입력 시 키보드 높이에 맞춰 댓글 입력 뷰 높이 조정
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .debug()
            .drive(onNext: { keyboardVisibleHeight in
                let window = UIApplication.shared.windows.first
                
                if keyboardVisibleHeight > 0.0 {
                    self.postView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardVisibleHeight, right: 0)
                    UIView.animate(withDuration: 0) {
                        self.replyContainer.snp.remakeConstraints {
                            $0.right.left.equalToSuperview().inset(12)
                            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardVisibleHeight - window!.safeAreaInsets.bottom)
                        }
                        self.view.layoutIfNeeded()
                    }
                } else {
                    self.postView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    UIView.animate(withDuration: 0) {
                        self.replyContainer.snp.remakeConstraints {
                            $0.right.left.equalToSuperview().inset(12)
                            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
                        }
                        self.view.layoutIfNeeded()
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        // MARK: 화면 터치시 키보드 내리기 (대댓글 작성일 때만)
        self.postView.rx
            .anyGesture(.tap(), .swipe(direction: .up))
            .when(.recognized)
            .withLatestFrom(self.viewModel.isSubReplyInputting)
            .bind {
                if $0 != nil {
                    self.viewModel.isSubReplyInputting.onNext(nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Private Funcs
    private func makeView() {
//        postView.makeView()
        postView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
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
    }
    
    private func setRightButtons(set: Bool) {
        self.navigationItem.rightBarButtonItem = .menuButton()
        let alert = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
        
        
        if set {
            let delete = UIAlertAction(title: "삭제", style: .default) { _ in
                self.deletingConfirmAlert()
            }
            let modify = UIAlertAction(title: "수정", style: .default) { _ in
                let vc = NewPostViewController()
                try? vc.postToModify = self.viewModel.post.value()
                let naviVC = UINavigationController(rootViewController: vc)
                naviVC.modalPresentationStyle = .fullScreen
                self.present(naviVC, animated: true, completion: nil)
            }
            alert.addAction(delete)
            alert.addAction(modify)
    
//            self.navigationItem.setRightBarButtonItems(items, animated: false)
//            deleteButton.rx.tap.bind {
//                self.deletingConfirmAlert()
//            }.disposed(by: rightButtonsDisposeBag)
//            editButton.rx.tap.asObservable().withLatestFrom(viewModel.post)
//                .bind {
//                    let vc = NewPostViewController()
//                    vc.postToModify = $0
//                    let naviVC = UINavigationController(rootViewController: vc)
//                    naviVC.modalPresentationStyle = .fullScreen
//                    self.present(naviVC, animated: true, completion: nil)
//                }.disposed(by: rightButtonsDisposeBag)
        }
        
        let report = UIAlertAction(title: "신고", style: .default)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(report)
        alert.addAction(cancel)
        
        self.navigationItem.rightBarButtonItem!
            .rx.tap
            .bind {
                self.present(alert, animated: true, completion: nil)
            }.disposed(by: self.disposeBag)
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
