//
//  ScheduleCalendarCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/23.
//

class ScheduleCalendarCell: FSCalendarCell {
    static let identifier = "ScheduleCalendarCell"
    
    var eventTitleLabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(eventTitleLabel)
        
        eventTitleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        self.titleLabel.snp.removeConstraints()
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.left.right.equalToSuperview()
        }
        
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
