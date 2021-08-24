//
//  SetRoutineView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/24.
//

import Foundation

class SetRoutineView: UIView {
    let routineCollectionLayout = UICollectionViewFlowLayout()
    
    var dateLabel = UILabel().then {
        $0.text = "8월 24일 (화)"
    }
    var leftButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.left")!, for: .normal)
        $0.tintColor = .black
    }
    var rightButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.right")!, for: .normal)
        $0.tintColor = .black
    }
    
    lazy var routineCollection = UICollectionView(frame: .zero, collectionViewLayout: routineCollectionLayout).then {
        $0.backgroundColor = .white
        $0.allowsMultipleSelection = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(dateLabel)
        self.addSubview(leftButton)
        self.addSubview(rightButton)
        self.addSubview(routineCollection)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(8)
        }
        leftButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.left.equalToSuperview().inset(8)
        }
        rightButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.right.equalToSuperview().inset(8)
        }
        routineCollection.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(Constants.RoutineCellSize)
            $0.left.equalToSuperview().inset(12)
            $0.right.equalToSuperview()
        }
        
//        routineCollection.contentInset.top = (routineCollection.bounds.height - Constants.RoutineCellSize) / 2.0
    }
}
