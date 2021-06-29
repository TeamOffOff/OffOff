//
//  TestView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/06/29.
//

import UIKit
import SnapKit
import Then

class TestView: UIStackView {
    
    lazy var idTextField = UITextField().then {
        $0.placeholder = "Type Your ID"
        $0.backgroundColor = .green
    }
    
    lazy var passwordTextField = UITextField().then {
        $0.placeholder = "Type Your password"
        $0.backgroundColor = .red
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = .yellow
        self.axis = .vertical
        self.alignment = .fill
        self.distribution = .fillEqually
        self.spacing = 25
        self.addArrangedSubview(idTextField)
        self.addArrangedSubview(passwordTextField)
    }
}

#if canImport(SwiftUI) && DEBUG

import SwiftUI
@available(iOS 13.0, *)
struct TestViewPreview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = TestView(frame: .zero)
            view.setupView()
            return view
        }.previewLayout(.sizeThatFits)
    }
}

#endif
