//
//  RoutineTableViewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/02.
//

import UIKit

class RoutineTableViewCell: UITableViewCell {

    static let identifier = "RoutineTableViewCell"
    
    var titleLabel = UILabel().then {
        $0.backgroundColor = .blue
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    var timeLabel = UILabel().then {
        $0.backgroundColor = .yellow
        $0.textAlignment = .right
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(timeLabel)
        
        titleLabel.snp.makeConstraints {
            $0.height.width.equalTo(self.contentView.snp.height).dividedBy(2.0)
            $0.left.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        timeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(25)
            $0.left.equalTo(titleLabel.snp.right).offset(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
