//
//  NameEmailViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/20.
//

import UIKit
import RxSwift
import RxCocoa

class PrivacyInfoViewController: UIViewController {

    lazy var privacyView = PrivacyInfoView()
    var birthdayPicker: UIDatePicker?
    
    let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = privacyView
        self.title = "개인정보"
        privacyView.makeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDatePicker(textField: privacyView.birthdayTextField)
        privacyView.nameTextField.delegate = self
        privacyView.emailTextField.delegate = self
        privacyView.emailTextField.keyboardType = .emailAddress
        
        // ViewModel 생성
        let viewModel = PrivacyInfoViewModel(
            input: (
                nameText: privacyView.nameTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                emailText: privacyView.emailTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                birthdayText: privacyView.birthdayTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                nextButtonTap: privacyView.nextButton.rx.tap.asSignal()
            )
        )
        
        // bind results
        viewModel.isNameConfirmed
            .drive(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)

        viewModel.isEmailConfirmed
            .drive(onNext: {
                if $0 {
                    self.privacyView.emailConfirmLabel.text = "사용가능한 이메일 주소입니다."
                } else {
                    self.privacyView.emailConfirmLabel.text = "이미 사용중인 이메일 주소입니다."
                    SharedSignUpModel.model.information.email = ""
                }
            })
            .disposed(by: disposeBag)

        viewModel.isBirthdayConfirmed
            .drive(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.isNextEnabled
            .drive(onNext: {
                self.privacyView.nextButton.isUserInteractionEnabled = $0
                self.privacyView.nextButton.backgroundColor = $0 ? .g4 : .g1
            })
            .disposed(by: disposeBag)
        
        viewModel.isValidatedToProgress
            .drive(onNext: {
                if $0 {
                    self.navigationController?.pushViewController(ProfileViewController(), animated: true)
                }
            })
            .disposed(by: disposeBag)
    
        self.privacyView.backButton.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if SharedSignUpModel.model.information.name != "" {
            privacyView.nameTextField.text = SharedSignUpModel.model.information.name
        }
         
        if SharedSignUpModel.model.information.email != "" {
            privacyView.emailTextField.text = SharedSignUpModel.model.information.email
        }
        
        if SharedSignUpModel.model.information.birth != "" {
            privacyView.birthdayTextField.text = SharedSignUpModel.model.information.birth
        }
    }
}

extension PrivacyInfoViewController: UITextFieldDelegate {
    // textfield의 텍스트 길이제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text ?? ""
        
        var max = 0
        if textField == privacyView.nameTextField {
            max = Constants.USERID_MAXLENGTH
        } else {
            return true
        }
        
        guard let stringRange = Range(range, in: str) else { return false }
        let updatedText = str.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= max
    }
    
    // return 버튼 대응
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

// MARK: - 생년월일 입력 DatePicker 설정
extension PrivacyInfoViewController {
    func setDatePicker(textField: UITextField) {
        let screenWidth = Constants.SCREEN_SIZE.width
        birthdayPicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 300.0))
        birthdayPicker!.datePickerMode = .date
        if #available(iOS 13.4, *) {
            birthdayPicker!.preferredDatePickerStyle = .wheels
        }
        birthdayPicker!.locale = Locale(identifier: "ko_kr")
        birthdayPicker!.maximumDate = Date()
        birthdayPicker!.minimumDate = "1940-01-01".toDate()
        birthdayPicker!.setDate("2002-01-01".toDate()!, animated: false)
        textField.inputView = birthdayPicker
        
        birthdayPicker!.topRoundCorner(radius: 40.0)
        
        birthdayPicker!.rx.date
            .map { $0.toString() }
            .bind {
                self.privacyView.birthdayTextField.text = $0
            }
            .disposed(by: disposeBag)
    }
}
