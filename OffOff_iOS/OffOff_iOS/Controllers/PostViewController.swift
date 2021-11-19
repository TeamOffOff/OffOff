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
import RxRelay

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
    
    var postImages = BehaviorRelay<[ImageObject]>(value: [])
    
    var replyContainer = UIView().then {
        $0.backgroundColor = .w2
        $0.topRoundCorner(radius: 10.adjustedHeight)
    }
    var replyTextView = UITextView().then {
        $0.backgroundColor = .w2
        $0.font = .defaultFont(size: 12)
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.tintColor = .mainColor
        $0.autocorrectionType = .no
        $0.textContentType = .none
    }
    var replyButton = UIButton().then {
        $0.backgroundColor = .g1
        $0.setTitle("확인", for: .normal)
        $0.titleLabel?.font = .defaultFont(size: 12, bold: true)
        $0.titleLabel?.textColor = .white
        $0.setCornerRadius(10.adjustedHeight)
    }
    
    var loadingImageView = UIImageView().then {
        $0.backgroundColor = .g4
        $0.image = UIImage(named: "LodingIndicator")!.resize(to: CGSize(width: 30.adjustedWidth, height: 30.adjustedHeight))
        $0.contentMode = .top
    }
    
    var loadingView = UIView().then {
        $0.backgroundColor = .g4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingImageView.rotate(duration: 2.5)
        self.navigationController?.navigationBar.setAppearance()
        
        self.view.backgroundColor = .white
        self.view.addSubview(postView)
        self.view.addSubview(replyContainer)
        replyContainer.addSubview(replyTextView)
        replyContainer.addSubview(replyButton)
        self.view.addSubview(loadingView)
        self.view.addSubview(loadingImageView)
        self.makeView()
        
        replyTextView.delegate = self
        
//        self.postView.repliesTableView.rx.setDelegate(self).disposed(by: disposeBag)
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
                print(#fileID, #function, #line, "!@#$!@$!@$!@$@!")
                self.postView.titleLabel.text = $0!.title
                self.postView.authorLabel.text = $0!.author.nickname
                self.postView.contentTextView.text = $0!.content
                self.postView.dateLabel.text = $0!.date.toDate()!.toFormedString()
                self.postView.profileImageView.image = .DefaultPostProfileImage
//                self.postView.likeButton.setTitle("\($0!.likes.count)", for: .normal)
                self.postImages.accept($0!.image)
                if $0!.author.profileImage.count != 0 {
                    self.postView.profileImageView.image = $0!.author.profileImage.first!.body.toImage()
                }
                if $0?.author._id == Constants.loginUser?._id {
                    self.setRightButtons(set: true)
                } else {
                    self.setRightButtons(set: false)
                }
                
                self.loadingView.isHidden = true
                self.rotateRefreshIndicator(false)
            }
            .disposed(by: disposeBag)
        
        // 이미지 표시
        self.postView.imageTableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.postImages
            .skip(1)
            .filter { $0.count > 0 }
            .do { print(#fileID, #function, #line, "num: \($0.count)")}
            .bind(to: self.postView.imageTableView.rx.items) { (tv, row, item) in
                let cell = tv.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! ImageTableViewCell
                cell.image.onNext(item.body.toImage())
                return cell
            }
            .disposed(by: self.disposeBag)
        
        
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
            .drive(onNext: { keyboardVisibleHeight in
                let window = UIApplication.shared.windows.first
                
                if keyboardVisibleHeight > 0.0 {
                    self.postView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardVisibleHeight, right: 0)
                    UIView.animate(withDuration: 0) {
                        self.replyContainer.snp.remakeConstraints {
                            $0.right.left.equalToSuperview()
//                            $0.bottom.equalToSuperview().inset(keyboardVisibleHeight - window!.safeAreaInsets.bottom)
                            $0.bottom.equalToSuperview().inset(keyboardVisibleHeight)
                        }
                        self.view.layoutIfNeeded()
                    }
                } else {
                    self.postView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    UIView.animate(withDuration: 0) {
                        self.replyContainer.snp.remakeConstraints {
                            $0.right.left.equalToSuperview()
                            $0.bottom.equalToSuperview()
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
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        loadingImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(30.adjustedWidth)
        }
        postView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(50.adjustedHeight)
        }
        replyContainer.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        let window = UIApplication.shared.windows.first
        replyTextView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14.adjustedHeight)
            $0.bottom.equalToSuperview().inset(14.adjustedHeight + Double(window!.safeAreaInsets.bottom))
            $0.left.equalToSuperview().offset(12)
            $0.right.equalTo(replyButton.snp.left)
        }
        replyButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(11.adjustedWidth)
            $0.top.equalToSuperview().inset(11.adjustedHeight)
            $0.height.equalTo(24.adjustedHeight)
            $0.width.equalTo(47.adjustedWidth)
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
    
    private func rotateRefreshIndicator(_ on: Bool) {
        self.loadingImageView.isHidden = !on
        
        if on {
            self.loadingImageView.rotate(duration: 2.5)
        } else {
            self.loadingImageView.stopRotating()
        }
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

extension PostViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = postImages.value[indexPath.row].body.toImage()
        
        return tableView.frame.width / image.imageRatio
    }
}
