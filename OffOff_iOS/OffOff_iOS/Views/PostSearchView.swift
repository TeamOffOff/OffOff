//
//  PostSearchView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/13.
//

import UIKit

class PostSearchView: UIView {
    var upperView = UIView().then {
        $0.backgroundColor = .g4
        $0.bottomRoundCorner(radius: 30.adjustedHeight)
    }
    
    var postListTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(PostPreviewCell.self, forCellReuseIdentifier: PostPreviewCell.identifier)
    }
    
    var searchIcon = UIImageView().then {
        $0.image = .SEARCHIMAGE.resize(to: CGSize(width: 18.adjustedWidth, height: 18.adjustedHeight))
        $0.contentMode = .scaleAspectFit
    }
    
    var searchTextField = UITextField().then {
        $0.backgroundColor = .clear
        $0.clearButtonMode = .whileEditing
        $0.textColor = .w5
        $0.font = .defaultFont(size: 16, bold: true)
    }
    
    lazy var searchContainer = UIView().then {
        $0.backgroundColor = .w2
        $0.setCornerRadius(16.adjustedHeight)
        $0.addSubview(searchIcon)
        $0.addSubview(searchTextField)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(upperView)
        self.addSubview(postListTableView)
        self.addSubview(searchContainer)
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeView() {
        upperView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(270.adjustedHeight)
        }
        postListTableView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(350.adjustedWidth)
            $0.top.equalTo(upperView.snp.bottom).inset(37.adjustedHeight)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
        }
        searchContainer.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(upperView.snp.bottom).inset(74.adjustedHeight)
            $0.width.equalTo(320.adjustedWidth)
            $0.height.equalTo(41.adjustedHeight)
        }
        searchIcon.snp.makeConstraints {
            $0.width.height.equalTo(18.adjustedWidth)
            $0.left.equalToSuperview().inset(12.adjustedWidth)
            $0.centerY.equalToSuperview()
        }
        searchTextField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(searchIcon.snp.right).offset(16.adjustedWidth)
            $0.right.equalToSuperview().inset(6.5.adjustedWidth)
        }
    }
}
