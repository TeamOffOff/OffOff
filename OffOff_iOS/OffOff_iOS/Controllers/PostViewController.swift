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
    
    unowned var postCell: PostPreviewCell?
    
    var replyCellHeight = 125.0
    
    var postImages = BehaviorRelay<[ImageObject]>(value: [])
    
    var replyContainer = UIView().then {
        $0.backgroundColor = .white
        $0.topRoundCorner(radius: 20.adjustedHeight)
        $0.addShadow(location: .top, color: .lightGray, opacity: 0.75, radius: 2.5)
    }
    var replyBackgroundView = UIView().then {
        $0.backgroundColor = .w2
        $0.setCornerRadius(15.adjustedHeight)
    }
    var replyTextView = UITextView().then {
        $0.backgroundColor = .clear
        $0.font = .defaultFont(size: 12, bold: true)
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.tintColor = .mainColor
        $0.autocorrectionType = .no
        $0.textContentType = .none
        $0.textContainerInset = .zero
        $0.text = "댓글을 입력하세요."
        $0.textColor = .w4
    }
    var replyButton = UIButton().then {
        $0.backgroundColor = .w2
        $0.setTitle("확인", for: .normal)
        $0.tintColor = .g1
        $0.titleLabel?.font = .defaultFont(size: 12, bold: true)
        $0.setTitleColor(.g1, for: .normal)
        $0.makeBorder(color: UIColor.g1.cgColor, width: 2.adjustedWidth)
        $0.setCornerRadius(10.adjustedHeight)
    }
    
    var loadingImageView = UIImageView().then {
        $0.backgroundColor = .g4
        $0.image = UIImage(named: "LodingIndicator")!.resize(to: CGSize(width: 30.adjustedWidth, height: 30.adjustedHeight), isAlwaysTemplate: false)
        $0.contentMode = .top
    }
    
    var loadingView = UIView().then {
        $0.backgroundColor = .g4
    }

    var backgroundForIndicator = UIView().then {
        $0.backgroundColor = .g4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingImageView.rotate(duration: 2.5)
        navigationController?.navigationBar.setAppearance()
        
        view.backgroundColor = .white
        view.addSubview(backgroundForIndicator)
        view.addSubview(postView)
        view.addSubview(replyContainer)
        replyContainer.addSubview(replyBackgroundView)
        replyBackgroundView.addSubview(replyTextView)
        replyContainer.addSubview(replyButton)
        view.addSubview(loadingView)
        view.addSubview(loadingImageView)
        makeView()
        
        replyTextView.rx.setDelegate(self).disposed(by: disposeBag)
        replyTextViewSetUp()
        
        //        self.postView.repliesTableView.rx.setDelegate(self).disposed(by: disposeBag)
        postView.repliesTableView.rowHeight = UITableView.automaticDimension
        postView.repliesTableView.estimatedRowHeight = 400
        
        // view model
        viewModel = PostViewModel(
            contentId: postInfo?.id ?? "",
            boardType: postInfo?.type ?? "",
            likeButtonTapped: postView.likeButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    PostLikeModel(id: owner.postInfo!.id, type: owner.postInfo!.type, cell: owner.postCell!)
                },
            replyButtonTapped: replyButton.rx.tap
                .withUnretained(self)
                .filter { (owner, _) in
                    owner.replyTextView.text != "" && owner.replyTextView.text != nil
                }
                .do { _ in LoadingHUD.show() }
                .map { (owner, _) in
                    let reply = WritingReply(boardType: owner.postInfo!.type, postId: owner.postInfo!.id, parentReplyId: nil, content: owner.replyTextView.text)
                    return reply
                },
            bookmarkButtonTapped: postView.scrapButton.rx.tap
                .withUnretained(self)
                .map { (owner, _) in
                    (owner.postInfo!.id, owner.postInfo!.type)
                }
        )
        
        // Refresh Control 세팅
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        refreshControl.backgroundColor = .g4
        
        postView.refreshControl = refreshControl
        
        postView.refreshControl!.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .bind { (owner, _) in
                owner.rotateRefreshIndicator(true)
                owner.viewModel.reloadPost(contentId: owner.postInfo!.id, boardType: owner.postInfo!.type)
            }
            .disposed(by: disposeBag)
        
        // bind result
        viewModel.refreshing
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                refreshControl.endRefreshing()
                self?.rotateRefreshIndicator(false)
            }
            .disposed(by: disposeBag)
        
        postView.rx.didEndDragging
            .withUnretained(self)
            .bind { (owner, _) in
                if ((owner.postView.contentOffset.y + owner.postView.frame.size.height) >= owner.postView.contentSize.height)
                {
                    owner.viewModel.reloadReplies(contentId: owner.postInfo!.id, boardType: owner.postInfo!.type)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.post
            .observe(on: MainScheduler.instance)
            .filter { $0 != nil }
            .withUnretained(self)
            .bind { (owner, model) in
                owner.postView.titleLabel.text = model!.title
                owner.postView.contentTextView.text = model!.content
                owner.postView.dateLabel.text = model!.date.toDate()!.toFormedString()
                owner.postView.profileImageView.image = .DefaultPostProfileImage
                
                // activities
                owner.postView.likeLabel.label.text = "\(model!.likes.count)"
                owner.postView.scrapLabel.label.text = "\(model!.bookmarks.count)"
                
                owner.postImages.accept(model!.image)
                
                if let author = model!.author {
                    owner.postView.authorLabel.text = author.nickname
                    if author.profileImage.count != 0 {
                        owner.postView.profileImageView.image = author.profileImage.first!.body.toImage()
                    }
                    if author._id == Constants.loginUser?._id {
                        owner.setRightButtons(set: true)
                    } else {
                        owner.setRightButtons(set: false)
                    }
                } else {
                    owner.postView.authorLabel.text = "알 수 없음"
                }
        
                if !owner.loadingView.isHidden {
                    owner.rotateRefreshIndicator(false)
                }
                owner.loadingView.isHidden = true
                
            }
            .disposed(by: disposeBag)
        
        // 이미지 표시
        postView.imageTableView.rx.setDelegate(self).disposed(by: disposeBag)
        postImages
            .skip(1)
            .filter { $0.count > 0 }
            .bind(to: postView.imageTableView.rx.items) { (tv, row, item) in
                let cell = tv.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! ImageTableViewCell
                cell.image.onNext(item.body.toImage())
                return cell
            }
            .disposed(by: disposeBag)
        
        
        viewModel.postDeleted
            .observe(on: MainScheduler.instance)
            .filter { $0 }
            .withUnretained(self)
            .bind { (owner, _) in
                owner.navigationController?.popViewController(animated: true)
                if let frontVC = owner.navigationController?.topViewController as? PostListViewController {
                    frontVC.viewModel?.fetchPostList(boardType: frontVC.boardType!)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.liked
            .observe(on: MainScheduler.instance)
            .skip(1)
            .withUnretained(self)
            .do { (owner, type) in
                switch type {
                case .success:
                    owner.activityAlert(message: "좋아요를 했습니다.")
                    owner.postView.likeLabel.label.text = "\(Int(owner.postView.likeLabel.label.text!)! + 1)"
                case .already:
                    owner.activityAlert(message: "이미 좋아요한 게시글 입니다.")
                default:
                    owner.activityAlert(message: "오류가 발생했습니다.")
                }
            }
            .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { (owner, _) in
                owner.dismissAlert(animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.bookmarked
            .observe(on: MainScheduler.instance)
            .skip(1)
            .withUnretained(self)
            .do { (owner, type) in
                switch type {
                case .success:
                    owner.activityAlert(message: "스크랩을 했습니다.")
                    owner.postView.scrapLabel.label.text = "\(Int(owner.postView.scrapLabel.label.text!)! + 1)"
                case .cancel:
                    owner.activityAlert(message: "스크랩을 취소했습니다.")
                    owner.postView.scrapLabel.label.text = "\(Int(owner.postView.scrapLabel.label.text!)! - 1)"
                default:
                    owner.activityAlert(message: "오류가 발생했습니다.")
                }
            }
            .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { (owner, _) in
                owner.dismissAlert(animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.reported
            .observe(on: MainScheduler.instance)
            .skip(1)
            .withUnretained(self)
            .do { (owner, type) in
                switch type {
                case .success:
                    owner.activityAlert(message: "게시글 신고가 완료됐습니다.")
                case .cancel:
                    owner.activityAlert(message: "게시글 신고가 취소됐습니다.")
                default:
                    owner.activityAlert(message: "오류가 발생했습니다.")
                }
            }
            .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { (owner, _) in
                owner.dismissAlert(animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.replies
            .observe(on: MainScheduler.instance)
            .filter { $0 != nil }
            .map { $0! }
            .withUnretained(self)
            .do { (owner, replies) in
                owner.postCell?.commentLabel.label.text = "\(replies.count)"
                owner.postView.replyLabel.label.text = "\(replies.count)"
            }
            .map { $1 }
            .bind(to: postView.repliesTableView.rx.items) { [weak self] (tv, row, item) -> UITableViewCell in
                guard let self = self else { return UITableViewCell() }
                if item.parentReplyId != nil {
                    let cell = tv.dequeueReusableCell(withIdentifier: ChildrenRepliesTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! ChildrenRepliesTableViewCell
                    cell.containerView.backgroundColor = .w2
                    cell.boardTpye = self.postInfo?.type
                    cell.reply.onNext(item)
                    cell.activityAlert = self.activityAlert
                    cell.dismissAlert = self.dismissAlert
                    cell.presentMenuAlert = self.presentMenuAlert
                    cell.replies = self.viewModel.replies
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: RepliesTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! RepliesTableViewCell
                    cell.containerView.backgroundColor = .w2
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
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .bind { (owner, bool) in
                if bool != nil {
                    owner.replyTextView.becomeFirstResponder()
                } else {
                    owner.replyTextView.endEditing(true)
                }
            }
            .disposed(by: disposeBag)
        
        let alert = UIAlertController(title: "댓글이 등록됐습니다.", message: nil, preferredStyle: .alert)
        viewModel.replyAdded
            .observe(on: MainScheduler.instance)
            .filter { $0 }
            .withUnretained(self)
            .do { (owner, bool) in
                if bool {
                    owner.replyTextView.text = ""
                    owner.replyTextView.resignFirstResponder()
                    owner.present(alert, animated: true, completion: nil)
                    LoadingHUD.hide()
                }
            }
            .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { (owner, _) in
                alert.dismiss(animated: true, completion: nil)
                if owner.postView.bounds.size.height < owner.postView.contentSize.height {
                    owner.postView.scrollToBottom()
                }
            }
            .disposed(by: disposeBag)
        
        //        self.postView.makeView()
        
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else { return }
                let window = UIApplication.shared.windows.first
                
                if keyboardVisibleHeight > 0.0 {
                    self.postView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardVisibleHeight, right: 0)
                    UIView.animate(withDuration: 0) {
                        self.replyContainer.snp.remakeConstraints {
                            $0.right.left.equalToSuperview()
                            $0.bottom.equalToSuperview().inset(keyboardVisibleHeight - window!.safeAreaInsets.bottom)
                            //                            $0.bottom.equalToSuperview().inset(keyboardVisibleHeight)
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
        postView.rx
            .anyGesture(.tap(), .swipe(direction: .up))
            .when(.recognized)
            .withLatestFrom(viewModel.isSubReplyInputting)
            .bind { [weak self] in
                if $0 != nil {
                    self?.viewModel.isSubReplyInputting.onNext(nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Private Funcs
    private func makeView() {
        backgroundForIndicator.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(self.view.snp.height).dividedBy(3.0)
        }
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
        replyBackgroundView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20.adjustedWidth)
            $0.top.equalToSuperview().inset(12.adjustedWidth)
            $0.bottom.equalToSuperview().inset(14.adjustedHeight + Double(window!.safeAreaInsets.bottom))
            //            $0.top.equalTo(replyTextView).offset(-12.adjustedHeight)
            //            $0.bottom.equalTo(replyTextView).offset(12.adjustedHeight)
        }
        
        replyTextView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14.adjustedHeight)
            $0.bottom.equalToSuperview().inset(14.adjustedHeight)
            $0.left.equalTo(replyBackgroundView).inset(14.adjustedWidth)
            $0.right.equalTo(replyButton.snp.left).inset(-10)
        }
        replyButton.snp.makeConstraints {
            $0.right.equalTo(replyBackgroundView).inset(14.adjustedWidth)
            $0.bottom.equalTo(replyBackgroundView).inset(8.adjustedHeight)
            $0.height.equalTo(24.adjustedHeight)
            $0.width.equalTo(47.adjustedWidth)
        }
    }
    
    private func setRightButtons(set: Bool) {
        navigationItem.rightBarButtonItem = .menuButton()
        let alert = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
        
        
        if set {
            let delete = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
                self?.deletingConfirmAlert()
            }
            let modify = UIAlertAction(title: "수정", style: .default) { [weak self] _ in
                let vc = NewPostViewController()
                try? vc.postToModify = self?.viewModel.post.value()
                let naviVC = UINavigationController(rootViewController: vc)
                naviVC.modalPresentationStyle = .fullScreen
                self?.present(naviVC, animated: true, completion: nil)
            }
            alert.addAction(delete)
            alert.addAction(modify)
        }
        
        let report = UIAlertAction(title: "신고", style: .default) { [weak self] _ in
            self?.viewModel.reportButtonTapped.onNext(true)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(report)
        alert.addAction(cancel)
        
        navigationItem.rightBarButtonItem!
            .rx.tap
            .bind { [weak self] in
                self?.present(alert, animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    private func deletingConfirmAlert() {
        let alert = UIAlertController(title: "정말 삭제하시겠습니까??", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "예", style: .default) { [weak self] _ in self?.viewModel.deleteButtonTapped.onNext(Constants.loginUser) }
        let cancel = UIAlertAction(title: "취소", style: .default) { _ in alert.dismiss(animated: true, completion: nil) }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    var alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private func activityAlert(message: String) {
        alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
    
    private func dismissAlert(animated: Bool = true) {
        alert.dismiss(animated: true, completion: nil)
    }
    
    var menuAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private func presentMenuAlert(alert: UIAlertController) {
        menuAlert = alert
        present(menuAlert, animated: true, completion: nil)
    }
    
    private func rotateRefreshIndicator(_ on: Bool) {
        loadingImageView.isHidden = !on
        
        if on {
            loadingImageView.rotate(duration: 2.5)
        } else {
            loadingImageView.stopRotating()
        }
    }
    
    private func replyTextViewSetUp() {
        replyTextView.rx.didBeginEditing
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                if(owner.replyTextView.text == "댓글을 입력하세요." ) {
                    owner.replyTextView.text = nil
                    owner.replyTextView.textColor = .w5          //글자 색도 진한 색으로 바꿔줘야한다!
                    
                }}).disposed(by: disposeBag)
        
        replyTextView.rx.didEndEditing
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                if(owner.replyTextView.text == nil || owner.replyTextView.text == ""){
                    owner.replyTextView.text = "댓글을 입력하세요."
                    owner.replyTextView.textColor = .w4        //다시 placeholder 글자색으로(연한색)
                    
                }}).disposed(by: disposeBag)
        
        replyTextView.rx.text
            .withUnretained(self)
            .bind { (owner, text) in
                if text! != "댓글을 입력하세요." && !text!.isEmpty {
                    owner.replyButton.isUserInteractionEnabled = true
                    owner.replyButton.backgroundColor = .g1
                    owner.replyButton.setTitleColor(.white, for: .normal)
                } else {
                    owner.replyButton.isUserInteractionEnabled = false
                    owner.replyButton.backgroundColor = .w2
                    owner.replyButton.setTitleColor(.g1, for: .normal)
                }
            }
            .disposed(by: disposeBag)
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
