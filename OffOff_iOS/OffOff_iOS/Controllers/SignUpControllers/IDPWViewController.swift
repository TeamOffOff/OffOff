//
//  IDPWViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/18.
//

import UIKit

class IDPWViewController: UIViewController {
    
    lazy var idpwView = IDPWView(frame: .zero)
    
    override func loadView() {
        self.view = idpwView
        self.title = "아이디 및 비밀번호"
        self.navigationController?.navigationBar.barTintColor = .mainColor
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
