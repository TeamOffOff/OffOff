//
//  NameEmailViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/20.
//

import UIKit

class NameEmailViewController: UIViewController {

    lazy var nameEmailView = NameEmailView()
    
    override func loadView() {
        self.view = nameEmailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
