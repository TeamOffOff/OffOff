//
//  PostPreviewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/06.
//

import UIKit

class PostPreviewCell: UITableViewCell {
    static let identifier = "PostPreviewCell"
    
    var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.boldSystemFont(ofSize: 17)
    }
    var previewTextView = UILabel().then {
        $0.numberOfLines = 2
    }
    var authorLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textAlignment = .right
    }
    var dateLabel = UILabel().then {
        $0.textColor = .lightGray
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
        authorLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.right.equalToSuperview().inset(8)
            $0.left.equalTo(titleLabel.snp.left).inset(8)
        }
        dateLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        previewTextView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().inset(12)
            $0.right.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setData(post: PostModel) {
        titleLabel.text = post.metadata.title
        previewTextView.text = post.contents.content
        authorLabel.text = post.metadata.author
        dateLabel.text = post.metadata.date
    }
    
    private func addViews() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(authorLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(previewTextView)
    }
}
