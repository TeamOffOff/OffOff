//
//  SetRoutineViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/24.
//

import UIKit
import RxSwift

class SetRoutineViewController: UIViewController {
    let customView = SetRoutineView()
    var viewModel = SetRoutineViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(customView)
        self.view.backgroundColor = .gray.withAlphaComponent(0.5)

        customView.routineCollection.register(RoutineCell.self, forCellWithReuseIdentifier: RoutineCell.identifier)
        customView.routineCollection.rx.setDelegate(self).disposed(by: disposeBag)
        
        customView.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.25)
            $0.left.right.bottom.equalToSuperview()
        }
        
        viewModel.routines
            .bind(to: customView.routineCollection.rx.items(cellIdentifier: RoutineCell.identifier, cellType: RoutineCell.self)) { (row, element, cell) in
                cell.titleLabel.text = element
            }
            .disposed(by: disposeBag)
        
        viewModel.dateText
            .debug()
            .bind {
                self.customView.dateLabel.text = $0
            }
            .disposed(by: disposeBag)
    
        customView.makeView()
    }
}

extension SetRoutineViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.bounds.width
        let cellWidth = Constants.RoutineCellSize
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
