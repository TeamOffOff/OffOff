//
//  ShiftTableViewCell.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/02.
//

import UIKit
import RxSwift

class ShiftTableViewCell: UITableViewCell {

    static let identifier = "RoutineTableViewCell"
    
    var shift = BehaviorSubject<Shift?>(value: nil)
    var editingShift = Observable<Shift?>.just(nil)
    var disposeBag = DisposeBag()
    
    var titleLabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    var timeLabel = UILabel().then {
        $0.textAlignment = .right
    }
    
    var menuButton = UIButton().then {
        $0.backgroundColor = .black
        $0.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        self.shift
            .debug()
            .observeOn(MainScheduler.instance)
            .filter {
                $0 != nil
            }
            .bind {
                self.setupCell(shift: $0!)
            }
            .disposed(by: disposeBag)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(timeLabel)
        self.accessoryView = menuButton
        self.selectionStyle = .none
        
        self.shift
            .debug()
            .observeOn(MainScheduler.instance)
            .filter {
                $0 != nil
            }
            .bind {
                self.setupCell(shift: $0!)
            }
            .disposed(by: disposeBag)
        
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
        
        editingShift = self.menuButton.rx.tap.flatMap { _ -> Observable<Shift?> in
            return self.shift
                .filter {$0 != nil }
                .map {$0}
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell(shift: Shift) {
        self.titleLabel.text = String(shift.title.first!)
        self.timeLabel.text = UserRoutineManager.shared.getRoutineTime(startDate: shift.startTime, endDate: shift.endTime)
        self.titleLabel.textColor = UIColor(hex: shift.textColor)
        self.titleLabel.backgroundColor = UIColor(hex: shift.backgroundColor)
    }
}
