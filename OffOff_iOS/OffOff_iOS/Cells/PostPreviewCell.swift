//
//  PostPreviewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/06.
//

import UIKit
import SnapKit
import Then

class PostPreviewCell: UITableViewCell {
    static let identifier = "PostPreviewCell"
    
    var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.boldSystemFont(ofSize: 17)
    }
    var previewTextView = UILabel().then {
        $0.numberOfLines = 2
    }
    var dateAuthorLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textAlignment = .left
    }
    var likeLabel = TextWithIconView().then {
        $0.iconImageView.image = .ICON_LIKES_RED
        $0.label.text = "0 | "
    }
    var commentLabel = TextWithIconView().then {
        $0.iconImageView.image = .ICON_COMMENT_BLUE
        $0.label.text = "0"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        addViews()
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(8)
        }
        dateAuthorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().inset(12)
            $0.right.equalToSuperview().inset(8)
        }
        previewTextView.snp.makeConstraints {
            $0.top.equalTo(dateAuthorLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().inset(12)
            $0.right.equalToSuperview().inset(8)
        }
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(previewTextView.snp.bottom).offset(12)
            $0.height.equalTo(18)
            $0.bottom.equalToSuperview().inset(8)
            $0.right.equalToSuperview().inset(12)
        }
        likeLabel.snp.makeConstraints {
            $0.top.equalTo(previewTextView.snp.bottom).offset(12)
            $0.height.equalTo(18)
            $0.bottom.equalToSuperview().inset(8)
            $0.right.equalTo(commentLabel.iconImageView.snp.left)
        }
    }
    
    func setData(post: PostModel) {
        titleLabel.text = post.Title
        previewTextView.text = post.Content
        dateAuthorLabel.text = "\(post.Date) | \(post.Author)"
        likeLabel.label.text = "\(post.Likes) | "
        commentLabel.label.text = "\(post.reply_count)"
    }
    
    private func addViews() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(previewTextView)
        self.contentView.addSubview(dateAuthorLabel)
        self.contentView.addSubview(commentLabel)
        self.contentView.addSubview(likeLabel)
    }
}
