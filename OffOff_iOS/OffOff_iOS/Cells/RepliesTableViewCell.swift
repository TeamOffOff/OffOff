//
//  RepliesTableViewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/10/10.
//

import UIKit
import RxSwift
import RxCocoa

class RepliesTableViewCell: UITableViewCell {
    
    static let identifier = "RepliesTableViewCell"
    var reply = BehaviorSubject<Reply?>(value: nil)
    var boardTpye: String?
    var disposeBag = DisposeBag()
    var alertDisposeBag = DisposeBag()
    
    var activityAlert: ((_ title: String) -> Void)?
    var dismissAlert: ((_ animated: Bool) -> Void)?
    var presentMenuAlert: ((_ alert: UIAlertController) -> Void)?
    
    var replies = BehaviorSubject<[Reply]?>(value: nil)
    
    var isSubReplyInputting = BehaviorSubject<Reply?>(value: nil)
    
    var profileImageView = UIImageView().then {
        $0.image = .DefaultReplyProfileImage
        $0.contentMode = .scaleAspectFit
    }
    
    var nicknameLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .defaultFont(size: 12, bold: true)
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
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("0", for: .normal)
        $0.titleLabel?.textAlignment = .right
        $0.setImage(.ICON_LIKES_RED, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.contentHorizontalAlignment = .left
    }
    
    var menubutton = UIButton().then {
        $0.setTitle("...", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    var addSubReplyButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }
    
    lazy var containerView = UIView().then {
        $0.backgroundColor = .w2
        $0.setCornerRadius(20.adjustedHeight)
        
        $0.addSubview(profileImageView)
        $0.addSubview(nicknameLabel)
        $0.addSubview(dateLabel)
        $0.addSubview(contentTextView)
        $0.addSubview(likeButton)
        $0.addSubview(addSubReplyButton)
        $0.addSubview(menubutton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bindData()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.addSubview(containerView)
        
        makeView()
//        bindData()
    }
    
    private func makeView() {
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(3.5.adjustedWidth)
            $0.left.right.equalToSuperview().inset(20.adjustedWidth)
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
        }
        
        likeButton.snp.makeConstraints {
            $0.top.equalTo(dateLabel)
            $0.left.equalTo(dateLabel.snp.right).offset(8.adjustedWidth)
            //            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        addSubReplyButton.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.right.equalToSuperview().inset(8.0)
        }
        menubutton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameLabel)
            $0.width.equalTo(20)
            $0.right.equalToSuperview().inset(8.0)
            $0.left.equalTo(nicknameLabel.snp.right)
        }
    }
    
    func bindData() {
        self.disposeBag = DisposeBag()

        reply
            .filter { $0 != nil }
            .bind {
                //            self.profileImageView.image =
                self.nicknameLabel.text = $0!.author.nickname
                self.dateLabel.text = $0!.date
                self.contentTextView.text = $0!.content
                self.likeButton.setTitle("\($0!.likes.count)", for: .normal)
                
                if $0!.author.profileImage.count != 0 {
                    self.profileImageView.image = $0!.author.profileImage.first!.body.toImage()
                }
            }.disposed(by: disposeBag)
        
        self.likeButton.rx.tap.withLatestFrom(reply)
            .filter { $0 != nil }
            .flatMap {
                ReplyServices.likeReply(reply: PostActivity(boardType: self.boardTpye!, _id: $0!._id, activity: "likes"))
            }
            .do {
                if $0 != nil {
                    self.activityAlert!("좋아요를 했습니다.")
                    self.reply.onNext($0)
                } else {
                    self.activityAlert!("이미 좋아요를 누른 댓글입니다.")
                }
            }
            .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { _ in
                self.dismissAlert!(true)
            }.disposed(by: self.disposeBag)
        
        self.menubutton.rx.tap.withLatestFrom(reply)
            .filter { $0 != nil }
            .bind {
                self.showMenuAlert(reply: $0!)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(self.isSubReplyInputting, self.reply)
            .map { one, two -> Bool in
                if one == nil || two == nil {
                    return false
                }
                return one!._id == two!._id
            }
            .bind {
                if $0 {
                    self.contentView.makeBorder(color: UIColor.lightGray.cgColor, width: 1.0, cornerRadius: 0)
                } else {
                    self.contentView.removeBorder()
                }
            }
            .disposed(by: disposeBag)
        
        self.addSubReplyButton.rx.tap.withLatestFrom(self.reply)
            .bind {
                self.isSubReplyInputting.onNext($0)
            }
            .disposed(by: disposeBag)
    }
    
    private func showMenuAlert(reply: Reply) {
        self.alertDisposeBag = DisposeBag()
        let alert = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "삭제", style: .default) { _ in
            let delReply = DeletingReply(_id: reply._id, postId: reply.postId, boardType: reply.boardType, author: reply.author._id!, isChildReply: false)
            ReplyServices.deleteReply(reply: delReply)
                .filter { $0 != nil }
                .do {
                    self.activityAlert!("댓글을 삭제했습니다.")
                    var replies = [Reply]()
                    $0!.forEach {
                        replies.append($0)
                        if $0.childrenReplies != nil &&  $0.childrenReplies!.count > 0 {
                            replies.append(contentsOf: $0.childrenReplies!)
                        }
                    }
                    self.replies.onNext(replies)
                }
                .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
                .bind { _ in
                    self.dismissAlert!(true)
                }
                .disposed(by: self.alertDisposeBag)
        }
        
        let report = UIAlertAction(title: "신고", style: .default)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        if Constants.loginUser?._id == reply.author._id {
            alert.addAction(delete)
        }
        alert.addAction(report)
        alert.addAction(cancel)
    
        presentMenuAlert!(alert)
    }
}
