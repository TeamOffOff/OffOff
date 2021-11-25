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
    var pictureLabel = TextWithIconView().then {
        $0.label.textColor = .w5
        $0.label.font = .defaultFont(size: 10.5)
        $0.iconImageView.image = .PICTUREICON
        $0.iconImageView.tintColor = .w5
        $0.label.text = "1"
    }
    var likeLabel = TextWithIconView().then {
        $0.label.textColor = .w5
        $0.label.font = .defaultFont(size: 10.5)
        $0.iconImageView.image = .LIKEICON
        $0.iconImageView.tintColor = .w5
        $0.label.text = "0"
    }
    var commentLabel = TextWithIconView().then {
        $0.label.textColor = .w5
        $0.label.font = .defaultFont(size: 10.5)
        $0.iconImageView.image = .REPLYICON
        $0.iconImageView.tintColor = .w5
        $0.label.text = "0"
    }
    
    var imagePreview = UIImageView().then {
        $0.backgroundColor = .w3
        $0.contentMode = .center
        $0.setCornerRadius(12.adjustedHeight)
    }
    
    lazy var containerView = UIView().then {
        $0.backgroundColor = .w2
        $0.setCornerRadius(20.adjustedHeight)
        
        $0.addSubview(titleLabel)
        $0.addSubview(previewTextView)
        $0.addSubview(dateAuthorLabel)
        $0.addSubview(pictureLabel)
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
        self.imagePreview.snp.updateConstraints {
            $0.width.equalTo(78.adjustedWidth)
        }
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
        pictureLabel.snp.makeConstraints {
            $0.top.equalTo(previewTextView.snp.bottom).offset(2.adjustedHeight)
            $0.height.equalTo(12.adjustedHeight)
            $0.right.equalTo(likeLabel.iconImageView.snp.left).offset(-2.0)
        }
        likeLabel.snp.makeConstraints {
            $0.top.equalTo(previewTextView.snp.bottom).offset(2.adjustedHeight)
            $0.height.equalTo(12.adjustedHeight)
            $0.right.equalTo(commentLabel.iconImageView.snp.left).offset(-2.0)
        }
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(previewTextView.snp.bottom).offset(2.adjustedHeight)
            $0.height.equalTo(12.adjustedHeight)
            $0.right.equalTo(imagePreview.snp.left).inset(-9.adjustedWidth)
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
            .withUnretained(self)
            .bind { (owner, post) in
                if post!.image.isEmpty {
                    owner.imagePreview.snp.updateConstraints {
                        $0.width.equalTo(0)
                    }
                    owner.pictureLabel.isHidden = true
                } else {
                    owner.imagePreview.snp.updateConstraints {
                        $0.width.equalTo(78.adjustedWidth)
                    }
                    owner.imagePreview.image = post!.image.first!.body.toImage()
                    owner.pictureLabel.isHidden = false
                    owner.pictureLabel.label.text = "\(post!.image.count)"
                }
                
                owner.titleLabel.text = post!.title
                owner.previewTextView.text = post!.content
                
                owner.likeLabel.label.text = "\(post!.likes.count)"
                owner.commentLabel.label.text = "\(post!.replyCount)"
                
                
                let postDate = post!.date.toDate()!
                
                owner.dateAuthorLabel.text = "\(postDate.toFormedString()) | \(post!.author.nickname)"
            }
            .disposed(by: disposeBag)
    }
}

