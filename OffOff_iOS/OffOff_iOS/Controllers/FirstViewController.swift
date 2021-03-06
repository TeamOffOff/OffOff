//
//  FirstViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/18.
//

import UIKit
import RxSwift

class FirstViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    var imageView = UIImageView().then {
        $0.image = UIImage(named: "IconImage")
        $0.contentMode = .scaleAspectFit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(imageView)
        self.view.backgroundColor = .mainColor
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(130)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginCheck()
    }
    
    private func loginCheck() {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
        if let token = KeyChainController.shared.read(Constants.ServiceString, account: "AccessToken") {
            print("Auto logined... token:", token)
            UserServices.getUserInfo()
                .delaySubscription(.seconds(1), scheduler: MainScheduler.instance)
                .observe(on: MainScheduler.instance)
                .withUnretained(self)
                .bind { (owner, info) in
                    var targetVC: UIViewController?
                    
                    if info != nil {
                        Constants.loginUser = info
                        targetVC = TabBarController()
                    } else {
                        targetVC = LoginViewController()
                    }
                    targetVC!.modalPresentationStyle = .fullScreen
                    sceneDelegate.window?.rootViewController = targetVC!
                }
                .disposed(by: disposeBag)
        } else {
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            sceneDelegate.window?.rootViewController = vc
        }
    }
}
