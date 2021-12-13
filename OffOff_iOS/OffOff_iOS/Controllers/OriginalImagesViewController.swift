//
//  OriginalImagesViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/12/11.
//

import UIKit

import RxSwift

final class OriginalImagesViewController: UIViewController {
    
    let customView = OriginalImagesView()
    
    var viewModel: OriginalImagesViewModel!
    var disposeBag = DisposeBag()
    
    var postInformation: (id: String, type: String)!
    var firstIndex: Int!
    
    
    override func loadView() {
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = OriginalImagesViewModel(postInfo: postInformation)
        
        customView.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.originalImages
            .debug()
            .bind(to: customView.collectionView.rx.items(cellIdentifier: OriginalImagesViewCell.identifier, cellType: OriginalImagesViewCell.self)) { (row, element, cell) in
                cell.imageView.image = element
            }
            .disposed(by: disposeBag)
        
        customView.closeButton
            .rx.tap
            .bind {
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        customView.collectionView
            .rx.willEndDragging
            .bind { [weak self] (velocity, targetContentOffset) in
                guard let layout = self?.customView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
                
                let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
                
                let estimatedIndex = (self?.customView.collectionView.contentOffset.x)! / cellWidthIncludingSpacing
                let index: Int
                if velocity.x > 0 {
                    index = Int(ceil(estimatedIndex))
                } else if velocity.x < 0 {
                    index = Int(floor(estimatedIndex))
                } else {
                    index = Int(round(estimatedIndex))
                }
                
                targetContentOffset.pointee = CGPoint(x: CGFloat(index) * cellWidthIncludingSpacing, y: 0)
            }
            .disposed(by: disposeBag)
        
    }
    
}

extension OriginalImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return customView.collectionView.frame.size
    }
}
