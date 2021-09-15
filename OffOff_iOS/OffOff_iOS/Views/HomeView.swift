//
//  HomeView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import UIKit

class HomeView: UIStackView {
    init(_ frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.spacing = 8.0
        self.distribution = .fillEqually
        let cardView = CardView(.zero)
        self.addArrangedSubview(cardView)
        let lab = UILabel()
        lab.backgroundColor = .yellow
        lab.text = "@@@@@@@"
        cardView.addContent(lab)
        self.addArrangedSubview(CardView(.zero))
        self.addArrangedSubview(CardView(.zero))
        self.addArrangedSubview(CardView(.zero))
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CardView: UIStackView {
    var titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12.0)
        $0.text = "Title"
    }
    let contentView = UIView().then {
        $0.backgroundColor = .lightGray
    }
    
    init(_ frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.addArrangedSubview(titleLabel)
        self.addArrangedSubview(contentView)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addContent(_ content: UIView) {
        self.contentView.addSubview(content)
        content.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct HomeViewPreview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = HomeView(.zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}

#endif

