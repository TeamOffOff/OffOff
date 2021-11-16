//
//  NewPostView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/11.
//

import UIKit
import RxSwift

class NewPostView: UIView {
    var backgroundView = UIView().then {
        $0.backgroundColor = .g4
//        $0.clipsToBounds = true
        $0.layer.cornerRadius = 30.adjustedHeight
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
    
    var titleTextField = UITextField().then {
        $0.font = .defaultFont(size: 18, bold: true)
        $0.textColor = .white
        
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .left
        $0.attributedPlaceholder = NSAttributedString(
            string: "제목",
            attributes: [.font: UIFont.defaultFont(size: 18, bold: true), .foregroundColor: UIColor.w4]
        )
    }
    
    var lineView = UIView().then {
        $0.backgroundColor = .g2
    }
    
    var contentTextView = UITextView().then {
        $0.font = .defaultFont(size: 14)
        $0.textColor = .white
        $0.backgroundColor = .g4
        $0.isScrollEnabled = false
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
    }
    
    var addPictureButton = UIButton().then {
        $0.setImage(.CAMERA.resize(to: CGSize(width: 13.94.adjustedWidth, height: 13.71.adjustedHeight)), for: .normal)
        $0.imageView?.tintColor = .g4
        $0.imageView?.contentMode = .center
        $0.backgroundColor = .w3
        $0.setCornerRadius(10.64.adjustedHeight)
    }
    
    let collectionViewLayout = UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 0.0
        $0.minimumInteritemSpacing = 0.0
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    lazy var addingImagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
        $0.backgroundColor = .g4
        $0.isScrollEnabled = true
        $0.register(AddingImagesCollectionViewCell.self, forCellWithReuseIdentifier: AddingImagesCollectionViewCell.identifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(backgroundView)
        self.addSubview(titleTextField)
        self.addSubview(lineView)
        self.addSubview(contentTextView)
        self.addSubview(addPictureButton)
        self.addSubview(addingImagesCollectionView)
        makeView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeView() {
        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20.adjustedHeight)
            $0.left.equalToSuperview().inset(34.adjustedWidth)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(16.adjustedHeight)
            $0.height.equalTo(1)
            $0.left.right.equalToSuperview().inset(33.adjustedWidth)
        }
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(21.adjustedHeight)
            $0.left.right.equalToSuperview().inset(33.adjustedWidth)
        }
        addingImagesCollectionView.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(16.adjustedHeight)
            $0.left.equalToSuperview().inset(30.adjustedWidth)
            $0.right.equalToSuperview()
            $0.height.equalTo(68.adjustedHeight)
        }
        addPictureButton.snp.makeConstraints {
            $0.top.equalTo(addingImagesCollectionView.snp.bottom).offset(38.adjustedHeight)
            $0.left.equalToSuperview().inset(31.adjustedWidth)
            $0.width.height.equalTo(30.adjustedWidth)
        }
        
        backgroundView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(addPictureButton).offset(22.adjustedHeight)
        }
    }
}

class AddingImagesCollectionViewCell: UICollectionViewCell {
    static let identifier = "AddingImagesCollectionViewCell"
    
    var row: Int!
    var deletingAction: ((Int) -> Void)!
    var disposeBag = DisposeBag()
    
    var imageView = UIImageView().then {
        $0.setCornerRadius(10.adjustedHeight)
        $0.backgroundColor = .w3
        $0.contentMode = .scaleAspectFill
    }
    var removeButton = UIButton().then {
        $0.setImage(UIImage(named: "X")!.resize(to: CGSize(width: 7.25.adjustedWidth, height: 8.2.adjustedHeight)), for: .normal)
        $0.backgroundColor = .white
        $0.setCornerRadius(8.adjustedHeight)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(removeButton)
        
        imageView.snp.makeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.width.height.equalTo(60.adjustedWidth)
        }
        
        removeButton.snp.makeConstraints {
            $0.centerY.equalTo(imageView.snp.top)
            $0.centerX.equalTo(imageView.snp.right)
            $0.width.height.equalTo(16.adjustedWidth)
        }
        
        bindButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bindButton()
    }
    
    func bindButton() {
        disposeBag = DisposeBag()
        self.removeButton.rx.tap
            .bind {
                self.deletingAction(self.row)
            }
            .disposed(by: disposeBag)
    }
}
