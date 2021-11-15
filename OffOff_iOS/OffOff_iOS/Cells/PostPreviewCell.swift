//
//  PostPreviewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/06.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay

class PostPreviewCell: UITableViewCell {
    static let identifier = "PostPreviewCell"
    
    var postModel = BehaviorRelay<PostModel?>(value: nil)
    var replies = BehaviorSubject<[Reply]>(value: [])
    
    var disposeBag = DisposeBag()
    
    var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .defaultFont(size: 15)
        $0.adjustsFontForContentSizeCategory = true
    }
    var previewTextView = UILabel().then {
        $0.font = .defaultFont(size: 10.5)
        $0.textColor = .w5
        $0.adjustsFontForContentSizeCategory = true
    }
    var dateAuthorLabel = UILabel().then {
        $0.textColor = .w5
        $0.font = .defaultFont(size: 10.5)
        $0.textAlignment = .left
    }
    var likeLabel = TextWithIconView().then {
        $0.label.textColor = .w5
        $0.label.font = .defaultFont(size: 10.5)
        $0.iconImageView.image = .ICON_LIKES_RED
        $0.label.text = "0"
    }
    var commentLabel = TextWithIconView().then {
        $0.label.textColor = .w5
        $0.label.font = .defaultFont(size: 10.5)
        $0.iconImageView.image = .ICON_COMMENT_BLUE
        $0.label.text = "0"
    }
    
    var imagePreview = UIImageView().then {
        $0.backgroundColor = .w3
        $0.contentMode = .scaleAspectFit
        $0.setCornerRadius(12.adjustedHeight)
    }
    
    lazy var containerView = UIView().then {
        $0.backgroundColor = .w2
        $0.setCornerRadius(20.adjustedHeight)
        
        $0.addSubview(titleLabel)
        $0.addSubview(previewTextView)
        $0.addSubview(dateAuthorLabel)
        $0.addSubview(commentLabel)
        $0.addSubview(likeLabel)
        
        $0.addSubview(imagePreview)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(containerView)
        setupCell()
        setData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        setData()
    }
    private func setupCell() {
        containerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(3.5.adjustedHeight)
        }
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(26.adjustedWidth)
            $0.top.equalToSuperview().inset(11.adjustedHeight)
            $0.right.equalTo(imagePreview.snp.left).offset(9.adjustedWidth)
        }
        previewTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4.adjustedHeight)
            $0.left.equalToSuperview().inset(26.adjustedWidth)
            $0.right.equalTo(imagePreview.snp.left).offset(9.adjustedWidth)
        }
        dateAuthorLabel.snp.makeConstraints {
            $0.top.equalTo(previewTextView.snp.bottom).offset(2.adjustedHeight)
            $0.left.equalToSuperview().inset(26.adjustedWidth)
            $0.bottom.equalToSuperview().inset(15.adjustedHeight)
        }
        likeLabel.snp.makeConstraints {
            $0.top.equalTo(previewTextView.snp.bottom).offset(2.adjustedHeight)
            $0.height.equalTo(12.adjustedHeight)
            $0.right.equalTo(commentLabel.iconImageView.snp.left)
        }
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(previewTextView.snp.bottom).offset(2.adjustedHeight)
            $0.height.equalTo(18)
            $0.right.equalTo(imagePreview.snp.left).offset(9.adjustedWidth)
        }
        imagePreview.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview().inset(9.adjustedHeight)
            $0.width.equalTo(78.adjustedWidth)
        }
    }
    
    private func setData() {
        disposeBag = DisposeBag()
        
        postModel
            .filter { $0 != nil }
            .do(onNext: { post in
//                _ = ReplyServices.fetchReplies(of: post!._id!, in: post!.boardType).bind(to: self.replies)
            })
            .bind { post in
                if post!.image.isEmpty {
                    self.imagePreview.snp.updateConstraints {
                        $0.width.equalTo(0)
                    }
                } else {
                    self.imagePreview.image = post!.image.first!.body.toImage()
                }
                
                self.titleLabel.text = post!.title
                self.previewTextView.text = post!.content
                self.dateAuthorLabel.text = "\(post!.date) | \(post!.author.nickname)"
                self.likeLabel.label.text = "\(post!.likes.count) | "
                self.commentLabel.label.text = "\(post!.replyCount)"
            }
            .disposed(by: disposeBag)
    }
}

