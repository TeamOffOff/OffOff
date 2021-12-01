//
//  ChildrenRepliesTableViewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/10/19.
//

import UIKit
import RxSwift
import RxCocoa

class ChildrenRepliesTableViewCell: UITableViewCell {
    static let identifier = "ChildrenRepliesTableViewCell"
    
    var reply = BehaviorSubject<Reply?>(value: nil)
    var disposeBag = DisposeBag()
    var alertDisposeBag = DisposeBag()
    
    var boardTpye: String?
    var activityAlert: ((_ title: String) -> Void)?
    var dismissAlert: ((_ animated: Bool) -> Void)?
    var presentMenuAlert: ((_ alert: UIAlertController) -> Void)?
    
    weak var replies: BehaviorSubject<[Reply]?>?
    
    var profileImageView = UIImageView().then {
        $0.image = .DefaultReplyProfileImage
        $0.contentMode = .scaleAspectFit
    }
    
    var nicknameLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .defaultFont(size: 12, bold: true)
        $0.text = "알 수 없음"
    }
    
    var dateLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.textColor = .w5
        $0.font = .defaultFont(size: 8)
    }
    
    var contentTextView = UITextView().then {
        $0.backgroundColor = .clear
        $0.font = .defaultFont(size: 10)
        $0.isScrollEnabled = false
        $0.sizeToFit()
        $0.isUserInteractionEnabled = false
    }
    
    var likeButton = UIButton().then {
        $0.setImage(.LIKEICON.resize(to: CGSize(width: 11.39.adjustedWidth, height: 10.19.adjustedHeight)), for: .normal)
        $0.tintColor = .w5
        $0.backgroundColor = .w3
        $0.setCornerRadius(5.95.adjustedHeight)
    }
    
    var menubutton = UIButton().then {
        $0.setImage(.MOREICON.resize(to: CGSize(width: 1.96.adjustedWidth, height: 9.8.adjustedHeight)), for: .normal)
        $0.tintColor = .w5
        $0.backgroundColor = .w3
        $0.setCornerRadius(5.95.adjustedHeight)
    }
    
    lazy var buttonStackView = UIStackView(arrangedSubviews: [likeButton, menubutton]).then {
        $0.backgroundColor = .clear
        $0.axis = .horizontal
        $0.spacing = 3.57.adjustedWidth
        $0.distribution = .fillEqually
    }
    
    var subImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .SubReplyArrow
    }
    
    var likeLabel = TextWithIconView().then {
        $0.iconImageView.image = .LikeIconFill
        $0.iconImageView.tintColor = .g2
        $0.label.text = "0"
        $0.label.font = .defaultFont(size: 12)
        $0.label.textColor = .g2
    }
    
    lazy var containerView = UIView().then {
        $0.backgroundColor = .w2
        $0.setCornerRadius(20.adjustedHeight)
        
        $0.addSubview(profileImageView)
        $0.addSubview(nicknameLabel)
        $0.addSubview(dateLabel)
        $0.addSubview(contentTextView)
        $0.addSubview(buttonStackView)
        $0.addSubview(likeLabel)
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(subImage)
        self.contentView.addSubview(containerView)
        bindData()
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bindData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bindData()
    }
    
    private func makeView() {
        subImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(23.adjustedWidth)
            $0.top.equalToSuperview().inset(37.5.adjustedHeight)
            $0.width.equalTo(19.adjustedWidth)
            $0.height.equalTo(16.52.adjustedHeight)
        }
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(3.5.adjustedWidth)
            $0.left.equalTo(subImage.snp.right).offset(7.adjustedWidth)
            $0.right.equalToSuperview().inset(20.adjustedWidth)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(11.adjustedHeight)
            $0.left.equalToSuperview().inset(14.adjustedWidth)
            $0.width.height.equalTo(20.0.adjustedWidth)
        }
        nicknameLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(5.adjustedWidth)
            $0.centerY.equalTo(profileImageView)
        }
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(5.adjustedWidth)
            $0.left.right.equalToSuperview().inset(13.adjustedWidth)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(7.adjustedHeight)
            $0.left.equalTo(profileImageView)
            $0.bottom.equalToSuperview().inset(7.adjustedHeight)
        }
        
        likeLabel.snp.makeConstraints {
            $0.left.equalTo(dateLabel.snp.right).offset(12.adjustedWidth)
            $0.centerY.equalTo(dateLabel)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.right.equalToSuperview().inset(26.adjustedWidth)
            $0.width.equalTo(49.adjustedWidth)
            $0.height.equalTo(16.67.adjustedHeight)
        }
    }
    
    private func bindData() {
        disposeBag = DisposeBag()
        
        reply
            .filter { $0 != nil }
            .map { $0! }
            .withUnretained(self)
            .bind { (owner, reply) in
                //            self.profileImageView.image =
                owner.dateLabel.text = reply.date
                owner.contentTextView.text = reply.content
                owner.likeLabel.label.text = "\(reply.likes.count)"
                
                if let author = reply.author {
                    owner.nicknameLabel.text = author.nickname
                    if author.profileImage.count != 0 {
                        owner.profileImageView.image = author.profileImage.first!.body.toImage()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        likeButton.rx.tap.withLatestFrom(reply)
            .filter { $0 != nil }
            .withUnretained(self)
            .flatMap { (owner, reply) -> Observable<Reply?> in
                SubReplyServices.likeSubReply(likeSubReply: PostActivity(boardType: owner.boardTpye!, _id: reply!._id, activity: "likes"))
            }
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .do { (owner, reply) in
                if reply != nil {
                    owner.activityAlert!("좋아요를 했습니다.")
                    owner.reply.onNext(reply)
                } else {
                    owner.activityAlert!("이미 좋아요를 누른 댓글입니다.")
                }
            }
            .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] (reply) in
                self?.dismissAlert!(true)
            }
            .disposed(by: disposeBag)
        
        self.menubutton.rx.tap.withLatestFrom(reply)
            .filter { $0 != nil }
            .bind { [weak self] in
                self?.showMenuAlert(reply: $0!)
            }
            .disposed(by: disposeBag)
    }
    
    private func showMenuAlert(reply: Reply) {
        self.alertDisposeBag = DisposeBag()
        let alert = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let delReply = DeletingSubReply(_id: reply._id, boardType: reply.boardType, postId: reply.postId, parentReplyId: reply.parentReplyId!, author: reply.author!._id!)
            
            SubReplyServices.deleteSubReply(deletingSubReply: delReply)
                .filter { $0 != nil }
                .observe(on: MainScheduler.instance)
                .withUnretained(self)
                .filter { (owner, _) in owner.replies != nil}
                .do { (owner, replyList) in
                    owner.activityAlert!("댓글을 삭제했습니다.")
                    var replies = [Reply]()
                    replyList!.forEach {
                        replies.append($0)
                        if $0.childrenReplies != nil &&  $0.childrenReplies!.count > 0 {
                            replies.append(contentsOf: $0.childrenReplies!)
                        }
                    }
                    owner.replies!.onNext(replies)
                }
                .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
                .bind { (owner, _) in
                    owner.dismissAlert!(true)
                }
                .disposed(by: self.alertDisposeBag)
        }
        
        let report = UIAlertAction(title: "신고", style: .default)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        if let author = reply.author {
            if Constants.loginUser?._id == author._id {
                alert.addAction(delete)
            }
        }
        
        alert.addAction(report)
        alert.addAction(cancel)
        
        presentMenuAlert!(alert)
    }
}
