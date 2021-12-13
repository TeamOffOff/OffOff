//
//  SettingViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/12/11.
//

import UIKit

import RxSwift

class SettingViewController: UIViewController {

    let customView = SettingView()
    
    var disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customView.developerInfoButton
            .rx.tap
            .bind {
                
            }
            .disposed(by: disposeBag)
    }
    
}
