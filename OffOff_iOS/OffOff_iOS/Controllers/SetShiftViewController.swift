//
//  SetShiftViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/24.
//

import UIKit
import RxSwift
import RxGesture

class SetShiftViewController: UIViewController {
    let customView = SetRoutineView()
    var viewModel: SetShiftViewModel!
    let disposeBag = DisposeBag()
    
    let outterView = UIView().then { $0.backgroundColor = .clear }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeView()
        viewModel = SetShiftViewModel(
            input: (
                leftButtonTapped: customView.leftButton.rx.tap.asSignal(),
                rightButtonTapped: customView.rightButton.rx.tap.asSignal(),
                selectedShift: customView.routineCollection.rx.modelSelected(Shift.self).map { $0 }
            )
        )
        
        outterView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // bind outputs
        viewModel.shifts
            .bind(to: customView.routineCollection
                    .rx.items(cellIdentifier: RoutineCell.identifier, cellType: RoutineCell.self)) { (row, element, cell) in
                cell.titleLabel.text = element.title
                cell.titleLabel.textColor = UIColor(hex: element.textColor)
                cell.backgroundColor = UIColor(hex: element.backgroundColor)
            }
            .disposed(by: disposeBag)
        
        viewModel.dateText
            .debug()
            .bind {
                self.customView.dateLabel.text = $0
            }
            .disposed(by: disposeBag)
        
        // 새로운 시프트 저장처리
        viewModel.shiftSaved
            .bind {
                if $0 {
                    print("saved")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("failed")
                }
            }
            .disposed(by: disposeBag)
    
        customView.makeView()
    }
    
    //MARK: - Private functions
    private func makeView() {
        self.view.addSubview(customView)
        self.view.addSubview(outterView)
        self.view.backgroundColor = .clear

        customView.routineCollection.register(RoutineCell.self, forCellWithReuseIdentifier: RoutineCell.identifier)
        customView.routineCollection.rx.setDelegate(self).disposed(by: disposeBag)
        
        customView.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.25)
            $0.left.right.bottom.equalToSuperview()
        }
        outterView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.bottom.equalTo(customView.snp.top)
        }
    }
}

extension SetShiftViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.bounds.width
        let cellWidth = Constants.RoutineCellSize
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
