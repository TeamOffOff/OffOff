//
//  ProfileViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/23.
//

import UIKit

import RxSwift
import RxCocoa
import ZLPhotoBrowser

class ProfileViewController: UIViewController {
    
    let profileView = ProfileMakeView()
    let disposeBag = DisposeBag()
    var profileImagePicker = UIImagePickerController().then {
        $0.allowsEditing = true
    }
    
    override func loadView() {
        self.view = profileView
        self.title = "프로필"
        profileView.makeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.nickNameTextField.delegate = self
        profileImagePicker.delegate = self
        
        // viewModel
        let viewModel = SignUpViewModel(
            input: (
                nicknameText: profileView.nickNameTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .debounce(.milliseconds(5), scheduler: ConcurrentMainScheduler.instance)
                    .asDriver(onErrorJustReturn: ""),
                signUpButtonTap: profileView.signUpButton.rx.tap.asSignal(),
                imageUploadButtonTap: profileView.imageUploadButton.rx.tap.asSignal()
            )
        )
        
        // bind results
        viewModel.isNickNameConfirmed
            .drive(onNext: {
//                self.profileView.nickNameTextField.selectedLineColor
//                    = $0 ? .mainColor : .red
//                self.profileView.nickNameTextField.selectedTitleColor
//                    = $0 ? .mainColor : .red
//                self.profileView.nickNameTextField.title
//                    = $0 ?
//                    "\(self.profileView.nickNameTextField.text!)은(는) 사용가능한 닉네임입니다."
//                    : "\(self.profileView.nickNameTextField.text!)은(는) 사용할 수 없습니다."
                self.profileView.signUpButton.isUserInteractionEnabled = $0
                self.profileView.signUpButton.backgroundColor = $0 ? .g4 : .g1
            })
            .disposed(by: disposeBag)
        
        viewModel.signedUp
            .drive(onNext: { signedUp in
                print(signedUp)
                if signedUp {
                    let alert = UIAlertController(title: "회원가입을 완료했습니다.\n인증을 위해서 기입한 이메일을 확인해주세요", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default) { action in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isUploadingImage
            .bind {
                if $0 {
//                    self.imagePickingAlert()
                    let cameraConfig = ZLPhotoConfiguration.default().cameraConfiguration
                    ZLPhotoConfiguration.default().allowRecordVideo = false
                    ZLPhotoConfiguration.default().allowSelectGif = false
                    ZLPhotoConfiguration.default().maxSelectCount = 1
                    ZLPhotoConfiguration.default().editImageClipRatios = [.wh1x1]
                    ZLPhotoConfiguration.default().allowEditImage = true
                    ZLPhotoConfiguration.default().editAfterSelectThumbnailImage = true
                    ZLPhotoConfiguration.default().editImageTools = [.clip]
                    ZLPhotoConfiguration.default().allowSelectOriginal = false
//                    ZLPhotoConfiguration.default().themeColorDeploy = ZLPhotoThemeColorDeploy().
                    
                    // All properties of the camera configuration have default value
                    cameraConfig.sessionPreset = .hd1920x1080
                    cameraConfig.focusMode = .continuousAutoFocus
                    cameraConfig.exposureMode = .continuousAutoExposure
                    cameraConfig.flashMode = .off
                    cameraConfig.videoExportType = .mov
                    
                    let ps = ZLPhotoPreviewSheet()
                    
                    ps.selectImageBlock = { [weak self] (images, assets, isOriginal) in
                        self!.profileView.profileImageView.image = images.first!
                        SharedSignUpModel.model.subInformation.profileImage = [ImageObject(key: nil, body: images.first!.toBase64String())]
                    }
                    ps.showPhotoLibrary(sender: self)
                }
            }
            .disposed(by: disposeBag)
        
        self.profileView.backButton.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func imagePickingAlert() {
        let alert = UIAlertController(title: "선택", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let camera = UIAlertAction(title: "카메라", style: .default) { _ in
            self.profileImagePicker.sourceType = .camera
            self.present(self.profileImagePicker, animated: true, completion: nil)
        }
        let album = UIAlertAction(title: "앨범", style: .default) { _ in
            self.profileImagePicker.sourceType = .photoLibrary
            self.present(self.profileImagePicker, animated: true, completion: nil)
        }
        
        alert.addAction(cancel)
        alert.addAction(camera)
        alert.addAction(album)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension ProfileViewController: UITextFieldDelegate {
    // textField text 길이 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text ?? ""
        let max = Constants.USERNICKNAME_MAXLENGTH
        
        guard let stringRange = Range(range, in: str) else { return false }
        let updatedText = str.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= max
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.profileView.profileImageView.image = image
            SharedSignUpModel.model.subInformation.profileImage = [ImageObject(key: nil, body: image.toBase64String())]
        }
        dismiss(animated: true, completion: nil)
        
    }
}
