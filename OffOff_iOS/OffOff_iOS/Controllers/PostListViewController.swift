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
    
    let activityNames = ["내가 쓴 글", "댓글 단 글", "스크랩한 글"]
    let customView = PostListView()
    
    let disposeBag = DisposeBag()
    var viewModel: PostListViewModel?
    
    let searchButton = UIBarButtonItem(image: .SEARCHIMAGE.resize(to: CGSize(width: 20, height: 20).resized(basedOn: .height)), style: .plain, target: nil, action: nil)
    let menuButton = UIBarButtonItem(image: .MOREICON.resize(to: CGSize(width: 4, height: 20).resized(basedOn: .height)), style: .plain, target: nil, action: nil)
    
    override func loadView() {
        self.view = customView
        self.navigationItem.backButtonTitle = ""
        self.title = boardName ?? ""
        
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.font: UIFont.defaultFont(size: 20)]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: .LEFTARROW.resize(to: CGSize(width: 25, height: 22).resized(basedOn: .height)), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItems = [searchButton]
        
        self.customView.postListTableView.rowHeight = 81.adjustedHeight
        self.customView.postListTableView.separatorStyle = .none
        
        rotateRefreshIndicator(true)
        
        if ActivityTypes(rawValue: boardType!) != nil {
            customView.newPostButton.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view model
        viewModel = PostListViewModel(boardType: boardType ?? "")
        
        
        // tableview refresh control
        let refreshControl = UIRefreshControl()
        if !activityNames.contains(boardName ?? "") {
            self.customView.postListTableView.refreshControl = refreshControl
            refreshControl.tintColor = .clear
        }
        
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
                let min = min(owner.customView.postListTableView.maxContentOffset.y, 100.adjustedHeight)
                if owner.customView.postListTableView.contentOffset.y <= min {
                    owner.customView.upperView.snp.updateConstraints {
                        $0.height.equalTo(150.adjustedHeight - owner.customView.postListTableView.contentOffset.y)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        self.customView.postListTableView.rx.didEndDragging
            .withUnretained(self)
            .filter { (owner, _) in !owner.activityNames.contains(owner.boardName ?? "") }
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
            .bind { (owner, indexPath) in
                if let cell = owner.customView.postListTableView.cellForRow(at: indexPath) as? PostPreviewCell {
                    let vc = PostViewController()
                    vc.postInfo = (id: cell.postModel.value!._id!, type: cell.postModel.value!.boardType)
                    vc.title = owner.boardName
                    vc.postCell = cell
                    owner.navigationController?.pushViewController(vc, animated: true)
                    owner.customView.postListTableView.deselectRow(at: indexPath, animated: false)
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
}
