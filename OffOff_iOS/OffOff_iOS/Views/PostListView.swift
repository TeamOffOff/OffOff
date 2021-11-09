//
//  PostListView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/09.
//

import UIKit

class PostListView: UIView {

    var upperView = UIView().then {
        $0.backgroundColor = .g4
        $0.bottomRoundCorner(radius: 30.adjustedHeight)
    }
    
    var postListTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(PostPreviewCell.self, forCellReuseIdentifier: PostPreviewCell.identifier)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(upperView)
        self.addSubview(postListTableView)
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
    }
}
