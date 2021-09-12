//
//  AddShiftViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/04.
//

import UIKit
import RxSwift

class AddShiftViewController: UIViewController {

    let customView = AddShiftView()
    var viewModel: AddShiftViewModel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(customView)
        
        customView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(self.view.snp.width).dividedBy(1.5)
//            $0.height.equalTo(self.view.snp.width)
        }
        
        viewModel = AddShiftViewModel(
            input: (
                badgeTapped: customView.badgeButton.rx.tap.asSignal(),
                titleText: customView.titleTextField.rx.text.asObservable(),
                cancelButtonTapped: customView.cancelButton.rx.tap.asSignal(),
                saveButtonTapped: customView.saveButton.rx.tap.asSignal(),
                startTimeButtonTapped: customView.startTimeButton.rx.tap.asSignal(),
                endTimeButtonTapped: customView.endTimeButton.rx.tap.asSignal(),
                pickedStartTime: customView.startTimePicker.rx.date,
                pickedEndTime: customView.endTimePicker.rx.date
            )
        )
        
        // bind outputs
        viewModel.textChanged
            .bind {
                if $0 != nil {
                    self.customView.badgeButton.setTitle("\($0!.prefix(1))", for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isEditingShiftColor
            .bind {
                if $0 {
                    let vc = ShiftColorSelectViewController()
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .currentContext
                    self.present(vc, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isDismissing
            .bind {
                if $0 {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isSaving
            .bind {
                print(#fileID, #function, #line, $0)
            }
            .disposed(by: disposeBag)
        
        viewModel.isShiftAdded
            .bind {
                if $0 {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: nil, message: "타이틀을 입력해주세요", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default) { _ in alert.dismiss(animated: true, completion: nil) }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isStartTimeEditing
            .bind {
                if $0 {
                    self.customView.endTimePicker.isHidden = true
                    UIView.animate(withDuration: 0.3) {
                        self.customView.startTimePicker.isHidden.toggle()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isEndTimeEditing
            .bind {
                if $0 {
                    self.customView.startTimePicker.isHidden = true
                    UIView.animate(withDuration: 0.3) {
                        self.customView.endTimePicker.isHidden.toggle()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.startTimeChanged
            .bind {
                self.customView.startTimeButton.setTitle($0, for: .normal)
            }
            .disposed(by: disposeBag)
        
        viewModel.endTimeChanged
            .bind {
                self.customView.endTimeButton.setTitle($0, for: .normal)
            }
            .disposed(by: disposeBag)
    }
}
