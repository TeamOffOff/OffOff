//
//  BoardListView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/08.
//

import UIKit

final class BoardListView: UIView {
    var greetingLabel = UILabel().then {
        $0.text = "안녕하세요!"
        $0.textColor = .white
        $0.font = .defaultFont(size: 22.0, bold: true)
    }
    
    var nicknameLabel = UILabel().then {
        $0.text = "홍길동 님"
        $0.textColor = .white
        $0.font = .defaultFont(size: 22.0, bold: true)
    }
    
    var menuButton = UIButton().then {
        $0.tintColor = .white
        $0.setImage(.MOREICON, for: .normal)
    }
    
    var messagesButton = UIButton().then {
        $0.setTitle("쪽지", for: .normal)
        $0.setTitleColor(.g4, for: .normal)
        $0.titleLabel?.font = .defaultFont(size: 11, bold: true)
        $0.backgroundColor = .g1
        $0.setCornerRadius(7.adjustedHeight)
    }
    
    var scrapsButton = UIButton().then {
        $0.setTitle("스크랩", for: .normal)
        $0.setTitleColor(.g4, for: .normal)
        $0.titleLabel?.font = .defaultFont(size: 11, bold: true)
        $0.backgroundColor = .g1
        $0.setCornerRadius(7.adjustedHeight)
    }
    
    lazy var upperView = UIView().then {
        $0.backgroundColor = .g4
        
        $0.bottomRoundCorner(radius: 30.adjustedHeight)
        $0.addSubview(greetingLabel)
        $0.addSubview(nicknameLabel)
        $0.addSubview(menuButton)
        $0.addSubview(messagesButton)
        $0.addSubview(scrapsButton)
    }
    
    var boardSearchView = UITextField().then {
        $0.backgroundColor = .w2
        $0.placeholder = "통합 검색"
        $0.font = .defaultFont(size: 15, bold: true)
        $0.setCornerRadius(22.adjustedHeight)
        $0.clearButtonMode = .whileEditing
        $0.tintColor = .g4
        $0.leftImage(.SEARCHIMAGE.resize(to: CGSize(width: 18.0.adjustedWidth, height: 18.0.adjustedHeight)), imageWidth: 18.0.adjustedWidth, padding: 24.adjustedWidth)
    }
    
    var postListTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(PostPreviewCell.self, forCellReuseIdentifier: PostPreviewCell.identifier)
        $0.isHidden = true
    }
    
    var boardCollectionViewFlowLayout = UICollectionViewFlowLayout()
    lazy var boardCollectionView = UICollectionView(frame: .zero, collectionViewLayout: boardCollectionViewFlowLayout).then {
        $0.backgroundColor = .white
        boardCollectionViewFlowLayout.scrollDirection = .vertical
//        boardCollectionViewFlowLayout.minimumLineSpacing = 18.0.adjustedHeight
        boardCollectionViewFlowLayout.minimumInteritemSpacing = 0.0.adjustedWidth
        $0.register(BoardCollectionViewCell.self, forCellWithReuseIdentifier: BoardCollectionViewCell.identifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(upperView)
        self.addSubview(boardSearchView)
        self.addSubview(boardCollectionView)
        self.addSubview(postListTableView)
        
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeView() {
        // upper view
        upperView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(270.adjustedHeight)
        }
        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(106.adjustedHeight)
            $0.left.equalToSuperview().inset(54)
        }
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(greetingLabel.snp.bottom).offset(12)
            $0.left.equalTo(greetingLabel)
        }
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(65.adjustedHeight)
            $0.right.equalToSuperview().inset(32.adjustedWidth)
            $0.width.equalTo(4)
            $0.height.equalTo(20)
        }
        messagesButton.snp.makeConstraints {
            $0.width.equalTo(42.adjustedWidth)
            $0.height.equalTo(30.adjustedHeight)
            $0.right.equalTo(menuButton)
            $0.top.equalTo(menuButton.snp.bottom).offset(20.adjustedHeight)
        }
        scrapsButton.snp.makeConstraints {
            $0.width.equalTo(42.adjustedWidth)
            $0.height.equalTo(30.adjustedHeight)
            $0.right.equalTo(menuButton)
            $0.top.equalTo(messagesButton.snp.bottom).offset(5.adjustedHeight)
        }
        
        boardSearchView.snp.makeConstraints {
            $0.height.equalTo(60.adjustedHeight)
            $0.width.equalTo(328.adjustedWidth)
            $0.centerY.equalTo(upperView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        boardCollectionView.snp.makeConstraints {
            $0.top.equalTo(boardSearchView.snp.bottom).offset(19.adjustedHeight)
            $0.left.right.equalToSuperview().inset(54.adjustedWidth)
            $0.bottom.equalToSuperview()
        }
        
        postListTableView.snp.makeConstraints {
            $0.top.equalTo(boardSearchView.snp.bottom).offset(19.adjustedHeight)
            $0.left.right.equalToSuperview().inset(54.adjustedWidth)
            $0.bottom.equalToSuperview()
        }
    }
}

final class BoardCollectionViewCell: UICollectionViewCell {
    static let identifier = "BoardCollectionViewCell"
    
    var boardView = UIView().then {
        $0.backgroundColor = .w2
        $0.setCornerRadius(14.adjustedHeight)
    }
    var titleLabel = UILabel().then {
        $0.font = .defaultFont(size: 12)
    }
    var badge = UIView().then {
        $0.backgroundColor = .g4
        $0.setCornerRadius(10.adjustedHeight)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(boardView)
        boardView.addSubview(titleLabel)
        self.contentView.addSubview(badge)
        
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeView() {
        boardView.snp.makeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.width.height.equalTo(82.0.adjustedWidth)
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8.adjustedHeight)
        }
        badge.snp.makeConstraints {
            $0.left.equalTo(boardView.snp.right).inset(10.adjustedWidth)
            $0.bottom.equalTo(boardView.snp.top).inset(10.adjustedHeight)
            $0.width.height.equalTo(20.adjustedWidth)
        }
    }
}
