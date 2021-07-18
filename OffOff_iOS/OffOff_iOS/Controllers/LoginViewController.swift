//
//  ViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/06/28.
//

import UIKit

class LoginViewController: UIViewController {
    
    lazy var loginView = LoginView(frame: .zero)
    private let loginViewModel = LoginViewModel()
    private lazy var loginStatus = Box(LoginStatus.none)
    
    override func loadView() {
        self.view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.idTextField.delegate = self
        loginView.passwordTextField.delegate = self
        loginView.loginButton.addTarget(self, action: #selector(onLoginButton), for: .touchUpInside)
        
        loginViewModel.loginModel.bind { _ in self.loginViewModel.login(loginStatus: self.loginStatus) }
        
        loginStatus.bind { [self] _ in
            if loginStatus.value == .successed {
                let controller = TabBarController()
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            } else if loginStatus.value == .failed {
                let alert = UIAlertController(title: "로그인 오류", message: "아이디 혹은 비밀번호가 일치하지 않습니다", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func onLoginButton(_: AnyObject) {
        loginViewModel.loginModel.value = LoginModel(id: loginView.idTextField.text, password: loginView.passwordTextField.text)
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
