//
//  ViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/06/28.
//

import UIKit

class LoginViewController: UIViewController {
    
    lazy var loginView = LoginView(frame: .zero)
    private let accountViewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(loginView)
        loginView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.snp.width).dividedBy(2.0)
            $0.centerY.equalToSuperview().inset(100)
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct PreviewController: PreviewProvider{
    static var previews: some View {
        LoginViewController().showPreview(.iPhone11Pro)
    }
}
#endif