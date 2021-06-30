//
//  LoginView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/06/29.
//

import UIKit

class LoginView: UIStackView {
    
    var idTextField = UITextField().then {
        $0.placeholder = "ID"
        #if DEBUG
        $0.backgroundColor = .cyan
        #endif
        print(#fileID, #function, #line, "")
    }
    
    var passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호"
        #if DEBUG
        $0.backgroundColor = .orange
        #endif
        print(#fileID, #function, #line, "")
    }
    
    var loginButton = UIButton().then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .purple
        print(#fileID, #function, #line, "")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "")
        #if DEBUG
        self.backgroundColor = .lightGray
        #endif
        self.setUpView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        print(#fileID, #function, #line, "")
        self.axis = .vertical
        self.distribution = .fillEqually
        self.alignment = .fill
        self.spacing = 10
        self.addArrangedSubview(idTextField)
        self.addArrangedSubview(passwordTextField)
        self.addArrangedSubview(loginButton)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct LoginViewPreview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = LoginView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif

