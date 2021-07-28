//
//  CommunityTableViewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/18.
//

import UIKit

class CommunityTableViewCell: UITableViewCell {
    var titleImage: UIImageView!
    var titleLabel: UILabel!
    static let identifier = "CommunityTableViewCell"
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        titleImage = UIImageView(image: UIImage(systemName: "cross")).then { $0.tintColor = .mainColor }
        titleLabel = UILabel().then {
            $0.text = "자유게시판"
            $0.textAlignment = .left
        }
        
        contentView.addSubview(titleImage)
        contentView.addSubview(titleLabel)
        
        titleImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(titleLabel.snp.height)
            $0.width.equalTo(titleImage.snp.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(titleImage.snp.right).offset(12)
            $0.right.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(12)
        }
    }
}
