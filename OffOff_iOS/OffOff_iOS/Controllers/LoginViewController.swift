//
//  ViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/06/28.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController {
    
    lazy var loginView = LoginView(frame: .zero)
    
    let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = loginView
        loginView.makeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView.idTextField.delegate = self
        loginView.passwordTextField.delegate = self
        
        // viewModel 생성
        let viewModel = LoginViewModel(
            input: (
                idText: loginView.idTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                passwordText: loginView.passwordTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                loginButtonTap: loginView.loginButton
                    .rx.tap
                    .asSignal()
            )
        )
        
        // signup button
        loginView.signupButton
            .rx.tap
            .bind {
                let vc = UINavigationController(rootViewController: IDPWViewController())
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        // bind to results
        viewModel.loginButtonAvailable
            .drive(onNext: {
                if $0 {
                    self.loginView.loginButton.isUserInteractionEnabled = true
                    self.loginView.loginButton.backgroundColor = .mainColor
                } else {
                    self.loginView.loginButton.isUserInteractionEnabled = false
                    self.loginView.loginButton.backgroundColor = .g1
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isSignedIn
            .drive(onNext: { result in
                switch result {
                case .Success:
                    print(#fileID, #function, #line, "")
//                    let controller = TabBarController()
//                    controller.modalPresentationStyle = .fullScreen
//                    self.present(controller, animated: true, completion: nil)
                case .NotExist:
                    let alert = UIAlertController(title: "로그인 오류", message: "존재하지 않는 회원입니다.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                case .PasswordNotCorrect:
                    let alert = UIAlertController(title: "로그인 오류", message: "아이디 혹은 비밀번호가 일치하지 않습니다", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                case .NoAuthorization:
                    let alert = UIAlertController(title: "로그인 오류", message: "이메일 인증이 완료되지 않았습니다.\n이메일을 확인해주세요.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isEntering
            .observe(on: MainScheduler.asyncInstance)
            .bind {
                if $0 {
                    let controller = TabBarController()
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text ?? ""
        
        var max = 0
        switch textField {
        case loginView.idTextField:
            max = Constants.USERID_MAXLENGTH
        case loginView.passwordTextField:
            max = Constants.USERPW_MAXLENGTH
        default:
            max = -1
        }
        guard let stringRange = Range(range, in: str) else { return false }
        let updatedText = str.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= max
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tf = textField as? TextField else { return }
        tf.errorMessage = ""
    }
}

enum LoginStatus {
    case successed
    case failed
    case none
}
