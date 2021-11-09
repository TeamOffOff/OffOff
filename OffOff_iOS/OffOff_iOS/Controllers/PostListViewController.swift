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
//        self.tableView = .init()
//        self.tableView.delegate = nil
//        self.tableView.dataSource = nil
        self.title = boardName ?? ""
        
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.font: UIFont.defaultFont(size: 20)]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: .LEFTARROW.resize(to: CGSize(width: 25.adjustedWidth, height: 22.adjustedHeight)), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItems = [menuButton, searchButton]
        
        self.customView.postListTableView.rowHeight = 81.adjustedHeight
//        self.customView.postListTableView.estimatedRowHeight = 200
//        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
//        tableView.register(PostPreviewCell.classForCoder(), forCellReuseIdentifier: PostPreviewCell.identifier)
        self.customView.postListTableView.separatorStyle = .none
//        tableView.separatorColor = .mainColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(#fileID, #function, #line, self.navigationItem)
//        print(#fileID, #function, #line, self.navigationController?.navigationBar.topItem)
//
//        // view model
        viewModel = PostListViewModel(boardType: boardType ?? "")
//
        
//
        // tableview refresh control
        let refreshControl = UIRefreshControl()
        self.customView.postListTableView.refreshControl = refreshControl

        Constants.currentBoard = self.boardType

        // bind result
        viewModel!.postList
            .observe(on: MainScheduler.instance)
            .do(onNext: { _ in refreshControl.endRefreshing() })
            .bind(to: self.customView.postListTableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.postModel.accept(element)
            }
            .disposed(by: disposeBag)
//
//
        refreshControl.rx.controlEvent(.valueChanged)
                    .bind(to: viewModel!.reloadTrigger)
                    .disposed(by: disposeBag)
        
        // table view scroll 대응
        self.customView.postListTableView.rx.didScroll
            .bind {
                if self.customView.postListTableView.contentOffset.y <= 75.adjustedHeight {
                    self.customView.upperView.snp.updateConstraints {
                        $0.height.equalTo(270.adjustedHeight - self.customView.postListTableView.contentOffset.y)
                    }
                }
            }
            .disposed(by: disposeBag)

//        // select row
//        self.tableView.rx
//            .itemSelected
//            .bind {
//                if let cell = self.tableView.cellForRow(at: $0) as? PostPreviewCell {
//                    let vc = PostViewController()
//                    vc.postInfo = (id: cell.postModel.value!._id!, type: cell.postModel.value!.boardType)
//                    vc.postCell = cell
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//            .disposed(by: disposeBag)
//
//        // inputs
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .bind { self.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)

//        self.navigationItem.rightBarButtonItem?
//            .rx.tap
//            .bind {
//                let vc = NewPostViewController()
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//            .disposed(by: disposeBag)
    }
}

// MARK: - Table view data source, delegate
//extension PostListViewController {
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 20.0
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//}
