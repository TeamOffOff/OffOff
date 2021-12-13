//
//  OriginalImagesView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/12/11.
//

import UIKit

final class OriginalImagesView: UIView {
    
    let flowLayout = UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.scrollDirection = .horizontal
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.register(OriginalImagesViewCell.self, forCellWithReuseIdentifier: OriginalImagesViewCell.identifier)
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    lazy var carouselProgressView = UIProgressView().then {
        $0.trackTintColor = .gray
        $0.progressTintColor = .white
    }
    
    var closeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setImage(UIImage.LEFTARROW, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(collectionView)
        self.addSubview(carouselProgressView)
        self.addSubview(closeButton)
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(80.adjustedHeight)
            $0.bottom.left.right.equalToSuperview()
        }
        
        carouselProgressView.snp.makeConstraints {
            $0.bottom.equalTo(collectionView.snp.bottom).inset(30.adjustedHeight)
            $0.left.right.equalToSuperview().inset(40.adjustedHeight)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(20.adjustedHeight)
        }
        
        
    }
}

final class OriginalImagesViewCell: UICollectionViewCell {
    static let identifier = "OriginalImagesViewCell"
    
    var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
