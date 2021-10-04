//
//  ScheduleView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/23.
//

import UIKit

class ScheduleView: UIView {
    
    var calendar = FSCalendar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(calendar)
        self.calendar.snp.makeConstraints { $0.top.left.right.equalTo(self.safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(self).multipliedBy(0.6)
        }
        initCalendar()
    }
    
    private func initCalendar() {
//        self.calendar.layer.cornerRadius = ThemeVariables.buttonCornerRadius
        self.calendar.layer.shouldRasterize = true
        self.calendar.layer.rasterizationScale = UIScreen.main.scale
        
        self.calendar.locale = Locale(identifier: "ko_KR")
        self.calendar.headerHeight = 50
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        self.calendar.appearance.headerDateFormat = "YYYY년 M월"
        self.calendar.appearance.headerTitleColor = .black
        self.calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 18)
        self.calendar.appearance.borderRadius = 0
        self.calendar.weekdayHeight = 40
        self.calendar.today = nil
        self.calendar.appearance.selectionColor = .clear
        self.calendar.appearance.titleSelectionColor = nil
        
        for weekday in self.calendar.calendarWeekdayView.weekdayLabels {
//            weekday.borderWidth = 1.0
//            weekday.borderColor = UIColor.lightGray.withAlphaComponent(0.25)
            if weekday.text == "일" {
                weekday.textColor = .red
            } else if weekday.text == "토" {
                weekday.textColor = .blue
            } else {
                weekday.textColor = .black
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
