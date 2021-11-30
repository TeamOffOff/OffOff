//
//  PostListTableViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

import UIKit
import RxSwift

class PostListViewController: UIViewController {
    var boardType: String?
    var boardName: String?
    
    let customView = PostListView()
    
    let disposeBag = DisposeBag()
    var viewModel: PostListViewModel?
    
    let searchButton = UIBarButtonItem(image: .SEARCHIMAGE.resize(to: CGSize(width: 20.adjustedWidth, height: 20.adjustedWidth)), style: .plain, target: nil, action: nil)
    let menuButton = UIBarButtonItem(image: .MOREICON.resize(to: CGSize(width: 4.adjustedWidth, height: 20.adjustedWidth)), style: .plain, target: nil, action: nil)
    
    var postViewController = PostViewController()
    
    override func loadView() {
        self.view = customView
        self.navigationItem.backButtonTitle = ""
        self.title = boardName ?? ""
        
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.font: UIFont.defaultFont(size: 20)]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: .LEFTARROW.resize(to: CGSize(width: 25.adjustedWidth, height: 22.adjustedHeight)), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItems = [menuButton, searchButton]
        
        self.customView.postListTableView.rowHeight = 81.adjustedHeight
        self.customView.postListTableView.separatorStyle = .none
        
        rotateRefreshIndicator(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view model
        viewModel = PostListViewModel(boardType: boardType ?? "")

        // tableview refresh control
        let refreshControl = UIRefreshControl()
        self.customView.postListTableView.refreshControl = refreshControl
        refreshControl.tintColor = .clear
        
        Constants.currentBoard = self.boardType
        
        // bind result
        viewModel!.postList
            .skip(1)
            .observe(on: MainScheduler.instance)
            .do { [weak self] _ in
                if !refreshControl.isRefreshing {
                    self?.rotateRefreshIndicator(false)
                }
            }
            .bind(to: customView.postListTableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.postModel.accept(element)
            }
            .disposed(by: disposeBag)
        
        viewModel!.refreshing
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                refreshControl.endRefreshing()
                self?.rotateRefreshIndicator(false)
            }
            .disposed(by: disposeBag)

        // Refresh control
//        self.customView.postListTableView.rx.didScroll
//            .bind {
////                self.scrollViewDidScroll(scrollView: self.customView.postListTableView)
//                self.updateProgress(with: self.customView.postListTableView.contentOffset.y)
//            }
//            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .debug()
            .withUnretained(self)
            .bind { (owner, _) in
                owner.rotateRefreshIndicator(true)
                owner.viewModel!.reloadTrigger.onNext(.newer)
            }
            .disposed(by: disposeBag)
        
        // table view scroll 대응
        customView.postListTableView.rx.didScroll
            .withUnretained(self)
            .bind { (owner, _) in
                if owner.customView.postListTableView.contentOffset.y <= 100.adjustedHeight {
                    owner.customView.upperView.snp.updateConstraints {
                        $0.height.equalTo(150.adjustedHeight - owner.customView.postListTableView.contentOffset.y)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        self.customView.postListTableView.rx.didEndDragging
            .withUnretained(self)
            .bind { (owner, _) in
                if ((owner.customView.postListTableView.contentOffset.y + owner.customView.postListTableView.frame.size.height) >= owner.customView.postListTableView.contentSize.height)
                {
                    owner.viewModel!.reloadTrigger.onNext(.older)
                }
            }
            .disposed(by: disposeBag)
    
        // select row
        self.customView.postListTableView.rx
            .itemSelected
            .withUnretained(self)
            .do { (owner, _) in owner.postViewController = PostViewController() }
            .bind { (owner, indexPath) in
                if let cell = owner.customView.postListTableView.cellForRow(at: indexPath) as? PostPreviewCell {
                    owner.postViewController.postInfo = (id: cell.postModel.value!._id!, type: cell.postModel.value!.boardType)
                    owner.postViewController.title = owner.boardName
                    owner.postViewController.postCell = cell
                    owner.customView.postListTableView.deselectRow(at: indexPath, animated: false)
                    owner.navigationController?.pushViewController(owner.postViewController, animated: true)
                }
            }
            .disposed(by: disposeBag)

        // inputs
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .bind { [weak self] in self?.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)

        self.customView.newPostButton
            .rx.tap
            .bind { [weak self] in
                let vc = NewPostViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        // searching
        self.searchButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                let vc = PostSearchViewController()
                vc.boardType = owner.boardType
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Funcs
    private func rotateRefreshIndicator(_ on: Bool) {
        self.customView.refreshingImageView.isHidden = !on
        
        if on {
            self.customView.refreshingImageView.rotate(duration: 2.5)
        } else {
            self.customView.refreshingImageView.stopRotating()
        }
    }
    
    private func updateProgress(with offsetY: CGFloat) {
        let maxPullDistance = 105.adjustedHeight
        
        guard !self.customView.refreshingImageView.isRotating() else { return }
        let progress = min(abs(offsetY / maxPullDistance), 1) * 10
        
        if progress >= 0 && progress < 2.5 {
            self.customView.refreshingImageView.image = nil
        } else if progress >= 2.5 && progress < 5.0 {
            self.customView.refreshingImageView.image = self.customView.refreshingImageView.animationImages![0]
        } else if progress >= 5.0 && progress < 7.5 {
            self.customView.refreshingImageView.image = self.customView.refreshingImageView.animationImages![1]
        } else {
            self.customView.refreshingImageView.image = self.customView.refreshingImageView.animationImages![2]
        }
    }
    
    // variable to save the last position visited, default to zero
    private var lastContentOffset: CGFloat = 0

    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            self.updateProgress(with: self.customView.postListTableView.contentOffset.y)
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
           // move down
        }

        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }

}
