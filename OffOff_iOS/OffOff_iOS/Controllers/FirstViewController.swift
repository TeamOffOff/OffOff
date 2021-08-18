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
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        loginCheck()
    }
    
    private func loginCheck() {
        if let token = UserDefaults.standard.string(forKey: "loginToken") {
            print("Auto logined... token:", token)
            UserServices.getUserInfo(token: token)
                .bind {
                    print($0)
                    let vc = ($0 != nil) ? TabBarController() : LoginViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: false)
                }
                .disposed(by: disposeBag)
        } else {
            self.present(LoginViewController(), animated: false)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
