//
//  PostListTableViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

// TODO: - 맨 위, 맨 아래로 스크롤 해서 새로운 데이터 로딩

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
    
    override func loadView() {
        self.view = customView
        self.navigationItem.backButtonTitle = ""
        self.title = boardName ?? ""
        
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.font: UIFont.defaultFont(size: 20)]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: .LEFTARROW.resize(to: CGSize(width: 25.adjustedWidth, height: 22.adjustedHeight)), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItems = [menuButton, searchButton]
        
        self.customView.postListTableView.rowHeight = 81.adjustedHeight
        self.customView.postListTableView.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view model
        viewModel = PostListViewModel(boardType: boardType ?? "")

        // tableview refresh control
        let refreshControl = CustomRefreshControl()
        self.customView.postListTableView.refreshControl = refreshControl
        
        Constants.currentBoard = self.boardType
        
        // bind result
        viewModel!.postList
            .observe(on: MainScheduler.instance)
            .bind(to: self.customView.postListTableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.postModel.accept(element)
            }
            .disposed(by: disposeBag)
        
        viewModel!.refreshing
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .bind {
                if refreshControl.isAnimating {
                    refreshControl.endRefreshing()
                }
            }
            .disposed(by: disposeBag)

        // Refresh control
//        self.customView.postListTableView.rx.didScroll
//            .bind {
//                refreshControl.updateProgress(with: self.customView.postListTableView.contentOffset.y)
//            }
//            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .debug()
            .bind {
                self.viewModel!.reloadTrigger.onNext(())
            }
            .disposed(by: disposeBag)
        
        // table view scroll 대응
        self.customView.postListTableView.rx.didScroll
            .bind {
                if self.customView.postListTableView.contentOffset.y <= 100.adjustedHeight {
                    self.customView.upperView.snp.updateConstraints {
                        $0.height.equalTo(270.adjustedHeight - self.customView.postListTableView.contentOffset.y)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        self.customView.postListTableView.rx.didEndDragging
            .bind { _ in
                if ((self.customView.postListTableView.contentOffset.y + self.customView.postListTableView.frame.size.height) >= self.customView.postListTableView.contentSize.height)
                {
                    self.viewModel!.reloadTrigger.onNext(())
                }
            }
            .disposed(by: disposeBag)

        // select row
        self.customView.postListTableView.rx
            .itemSelected
            .bind {
                if let cell = self.customView.postListTableView.cellForRow(at: $0) as? PostPreviewCell {
                    let vc = PostViewController()
                    vc.postInfo = (id: cell.postModel.value!._id!, type: cell.postModel.value!.boardType)
                    vc.title = self.boardName
                    vc.postCell = cell
                    self.customView.postListTableView.deselectRow(at: $0, animated: false)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)

        // inputs
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .bind { self.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)

        self.customView.newPostButton
            .rx.tap
            .bind {
                let vc = NewPostViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        // searching
        self.searchButton.rx.tap
            .bind { _ in
                let vc = PostSearchViewController()
                vc.boardType = self.boardType
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
