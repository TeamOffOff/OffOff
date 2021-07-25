//
//  ProfileMakeViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/23.
//

import UIKit

class ProfileMakeViewController: UIViewController {

    let profileView = ProfileMakeView(frame: .zero)
    
    var isNicknameVerified: Bool = false {
        didSet {
            if isNicknameVerified {
                profileView.nickNameTextField.selectedLineColor = .mainColor
                profileView.nickNameTextField.selectedTitleColor = .mainColor
                profileView.nickNameTextField.title = "\(profileView.nickNameTextField.text!)은(는) 사용가능한 닉네임입니다."
            } else {
                profileView.nickNameTextField.selectedLineColor = .red
                profileView.nickNameTextField.selectedTitleColor = .red
                profileView.nickNameTextField.title = "\(profileView.nickNameTextField.text!)은(는) 사용할 수 없습니다."
            }
        }
    }
    
    override func loadView() {
        self.view = profileView
        self.title = "프로필"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.nickNameTextField.addTarget(self, action: #selector(onNicknameTextFieldChanged), for: .editingChanged)
    }
    
    @objc func onNicknameTextFieldChanged(_ textField: TextField) {
        isNicknameVerified = SignUpViewModel.shared.isValidNickname(nickname: textField.text ?? "")
    }
}
