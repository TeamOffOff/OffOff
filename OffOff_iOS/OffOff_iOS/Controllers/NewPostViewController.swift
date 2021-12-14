//
//  NewPostViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import UIKit

import RxCocoa
import RxSwift
import RxGesture

import ZLPhotoBrowser

class NewPostViewController: UIViewController {
    let disposeBag = DisposeBag()
    let newPostView = NewPostView()
    
    var viewModel: NewPostViewModel!
    
    var postToModify: PostModel? = nil
    
    var textViewMaxHeight = Constants.SCREEN_SIZE.height / 3.5
    
    var textViewNeedToScroll = BehaviorSubject<Bool>(value: false)
    
    override func loadView() {
        self.view = newPostView
        self.view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "글 쓰기"
        
        self.newPostView.addingImagesCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let saveButton = UILabel(frame: CGRect(x: 0, y: 0, width: 47.adjustedWidth, height: 27.adjustedHeight)).then {
            $0.backgroundColor = .g1
            $0.text = "완료"
            $0.font = .defaultFont(size: 14, bold: true)
            $0.textColor = .g4
            $0.textAlignment = .center
            $0.setCornerRadius(8.04.adjustedHeight)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        var alert = UIAlertController(title: "제목을 입력해주세요.", message: nil, preferredStyle: .alert)
        
        self.navigationItem.rightBarButtonItem!.rx.tap
            .bind { _ in
                print(#fileID, #function, #line, "")
            }.disposed(by: disposeBag)
        
        // view model
        viewModel = NewPostViewModel(
            input: (
                titleText: newPostView.titleTextField
                    .rx.text
                    .orEmpty
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                contentText: newPostView.contentTextView
                    .rx.text
                    .orEmpty
                    .filter { $0 != "내용을 입력해주세요." }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                createButtonTap: saveButton.rx.tapGesture()
                    .when(.recognized),
                imageUploadButtonTapped: newPostView.addPictureButton.rx.tap,
                post: Observable.just(postToModify)
            )
        )
        
        // 수정일 때 세팅
        setModifyingMode(postToModify != nil)
        
        // 텍스트 뷰 크기 제한
        self.newPostView.contentTextView
            .rx.didChange
            .withUnretained(self)
            .bind { (owner, _) in
                let needToScrolling = self.newPostView.contentTextView.contentSize.height > owner.textViewMaxHeight
                
                owner.textViewNeedToScroll.onNext(needToScrolling)
            }
            .disposed(by: disposeBag)
        
        // 텍스트 뷰 PlaceHolder
        newPostView.contentTextView.rx.didBeginEditing
            .withUnretained(self)
            .bind{ (owner, _) in
                if(owner.newPostView.contentTextView.text == "내용을 입력해주세요.") {
                    owner.newPostView.contentTextView.text = nil
                    owner.newPostView.contentTextView.textColor = .white
                }
            }.disposed(by: disposeBag)
        
        newPostView.contentTextView.rx.didEndEditing
            .withUnretained(self)
            .bind { (owner, _) in
                if(owner.newPostView.contentTextView.text == nil || owner.newPostView.contentTextView.text == ""){
                    owner.newPostView.contentTextView.text = "내용을 입력해주세요."
                    owner.newPostView.contentTextView.textColor = .w3
                }
            }
            .disposed(by: disposeBag)
    
        // bind results
        self.viewModel.isCreating
            .observe(on: MainScheduler.instance)
            .bind {
                if $0 {
                    LoadingHUD.show()
                } else {
                    LoadingHUD.hide()
                }
            }
            .disposed(by: disposeBag)
        
        self.textViewNeedToScroll
            .skip(1)
            .withUnretained(self)
            .bind { (owner, needToScrolling) in
                if needToScrolling {
                    owner.newPostView.contentTextView.snp.remakeConstraints {
                        $0.top.equalTo(owner.newPostView.lineView.snp.bottom).offset(21.adjustedHeight)
                        $0.left.right.equalToSuperview().inset(33.adjustedWidth)
                        $0.height.equalTo(owner.textViewMaxHeight)
                    }
                } else {
                    owner.newPostView.contentTextView.snp.remakeConstraints {
                        $0.top.equalTo(owner.newPostView.lineView.snp.bottom).offset(21.adjustedHeight)
                        $0.left.right.equalToSuperview().inset(33.adjustedWidth)
                    }
                }
                
                owner.newPostView.contentTextView.isScrollEnabled = needToScrolling
                owner.newPostView.contentTextView.text = owner.newPostView.contentTextView.text
            }
            .disposed(by: disposeBag)
        
        self.viewModel.uploadingImages
            .withUnretained(self)
            .do { (owner, images) in
                if images.isEmpty {
                    owner.newPostView.addingImagesCollectionView.snp.updateConstraints {
                        $0.height.equalTo(0)
                    }
                } else {
                    owner.newPostView.addingImagesCollectionView.snp.updateConstraints {
                        $0.height.equalTo(68.adjustedHeight)
                    }
                }
            }
            .map { $1 }
            .bind(to: newPostView.addingImagesCollectionView.rx.items(cellIdentifier: AddingImagesCollectionViewCell.identifier, cellType: AddingImagesCollectionViewCell.self)) { [weak self] (row, element, cell) in
                cell.row = row
                cell.imageView.image = element
                cell.deletingAction = self?.deleteUploadingImage
            }
            .disposed(by: disposeBag)
        
        viewModel.isUploadingImage
            .bind {
                if $0 {
//                    self.imagePickingAlert()
                    let cameraConfig = ZLPhotoConfiguration.default().cameraConfiguration
                    ZLPhotoConfiguration.default().allowRecordVideo = false
                    ZLPhotoConfiguration.default().allowSelectGif = false
                    ZLPhotoConfiguration.default().maxSelectCount = 5
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
                        let images = self!.viewModel.uploadingImages.value + images
                        self!.viewModel.uploadingImages.accept(images)
                    }
                    ps.showPhotoLibrary(sender: self)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isTitleConfirmed
            .skip(1)
            .filter { $0 == false }
            .observe(on: MainScheduler.instance)
            .do { [weak self] _ in
                alert = UIAlertController(title: "제목을 입력해주세요.", message: nil, preferredStyle: .alert)
                self?.present(alert, animated: true, completion: nil)
            }
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        viewModel.isContentConfiremd
            .skip(1)
            .filter { $0 == false }
            .observe(on: MainScheduler.instance)
            .do { [weak self] _ in
                alert = UIAlertController(title: "내용을 입력해주세요.", message: nil, preferredStyle: .alert)
                self?.present(alert, animated: true, completion: nil)
            }
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        viewModel.postCreated
            .observe(on: MainScheduler.instance)
            .do { [weak self] _ in self?.viewModel.isCreating.onNext(false) }
            .filter { $0 != nil }
            .map { $0! }
            .withUnretained(self)
            .subscribe(onNext: { (owner, model) in
                if owner.postToModify == nil {
                    owner.navigationController?.popViewController(animated: true)
                    if let frontVC = owner.navigationController?.topViewController as? PostListViewController {
                        frontVC.viewModel?.fetchPostList(boardType: frontVC.boardType!)
                    }
                } else {
                    if let naviVC = owner.presentingViewController as? UINavigationController {
                        if let postVC = naviVC.topViewController as? PostViewController {
                            owner.dismiss(animated: true)
//                            postVC.viewModel.post.onNext(model)
//                            postVC.postInfo = (id: model._id!, type: model.boardType)
                            postVC.viewModel.reloadPost(contentId: model._id!, boardType: model.boardType)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setModifyingMode(_ on: Bool) {
        if on {
            self.title = "글 수정"
            self.newPostView.titleTextField.text = postToModify!.title
            self.newPostView.contentTextView.text = postToModify!.content
            self.viewModel.uploadingImages.accept(postToModify!.image.map { $0.body.toImage() })
            self.navigationController?.navigationBar.setAppearance()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
            self.navigationItem.leftBarButtonItem!.rx.tap
                .bind { [weak self] in self?.dismiss(animated: true, completion: nil) }.disposed(by: disposeBag)
        }
    }
    
    func deleteUploadingImage(_ at: Int) {
        var images = self.viewModel.uploadingImages.value
        images.remove(at: at)
        self.viewModel.uploadingImages.accept(images)
    }
}

extension NewPostViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 70.adjustedHeight, height: 68.adjustedHeight)
    }
}
