//
//  UnderlineSegmentedControl.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/09.
//

import UIKit
import RxSwift

class UnderlineSegmentedControl: UIView {
    let disposeBag = DisposeBag()
    
    private var buttonTitles: [String]!
    private var buttons: [UIButton]!
    private var indicator: UIView!
    
    var indicatorHeight: CGFloat = 2.0
    var textColor: UIColor = .black
    var indicatorColor: UIColor = .red
    var selectorTextColor: UIColor = .red
    
    public private(set) var selectedIndex = BehaviorSubject<Int>(value: 0)
    
    private func configureView() {
        createButton()
        configureIndicator()
        configureStackView()
    }
    
    convenience init(frame: CGRect, buttonTitles: [String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        configureView()
    }
    
    func setButtonTitles(buttonTitles: [String]) {
        self.buttonTitles = buttonTitles
        configureView()
    }
}

extension UnderlineSegmentedControl {
    private func configureStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureIndicator() {
        let indicatorWidth = frame.width / CGFloat(self.buttonTitles.count)
        indicator = UIView(frame: CGRect(x: 0, y: self.frame.height, width: indicatorWidth, height: indicatorHeight))
        indicator.backgroundColor = indicatorColor
        addSubview(indicator)
    }
    
    private func createButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        
        for (index, buttonTitle) in buttonTitles.enumerated() {
            let button: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle(buttonTitle, for: .normal)
                button.setTitleColor(textColor, for: .normal)
                return button
            }()
            
            button.rx.tap.bind {
                self.buttonSelected(selectedIndex: index)
                self.selectedIndex.onNext(index)
            }
            .disposed(by: disposeBag)
            
            buttons.append(button)
            // default selection == 0
            buttons[0].setTitleColor(selectorTextColor, for: .normal)
        }
    }
    
    private func buttonSelected(selectedIndex: Int) {
        for (index, button) in self.buttons.enumerated() {
            if index != selectedIndex {
                button.setTitleColor(textColor, for: .normal)
            } else {
                let indicatorPosition = frame.width / CGFloat(buttonTitles.count) * CGFloat(index)
                
                UIView.animate(withDuration: 0.3) {
                    self.indicator.frame.origin.x = indicatorPosition
                }
                button.setTitleColor(selectorTextColor, for: .normal)
            }
        }
    }
}
