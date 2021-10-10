//
//  PostListTableViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

// TODO: - 맨 위, 맨 아래로 스크롤 해서 새로운 데이터 로딩

import UIKit
import RxSwift

class PostListViewController: UITableViewController {
    var boardType: String?
    var boardName: String?
    let disposeBag = DisposeBag()
    var viewModel: PostListViewModel?
    
    override func loadView() {
        self.tableView = .init()
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.title = boardName ?? ""
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.barTintColor = .mainColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: nil)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(PostPreviewCell.classForCoder(), forCellReuseIdentifier: PostPreviewCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .mainColor
    }
    
    override func viewDidLoad() {
        // view model
        viewModel = PostListViewModel(boardType: boardType ?? "")
        
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // tableview refresh control
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        
        // bind result
        viewModel!.postList
            .observeOn(MainScheduler.instance)
            .do(onNext: { _ in refreshControl.endRefreshing() })
            .bind(to: self.tableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.postModel.accept(element)
            }
            .disposed(by: disposeBag)
        
        
        refreshControl.rx.controlEvent(.valueChanged)
                    .bind(to: viewModel!.reloadTrigger)
                    .disposed(by: disposeBag)

        // select row
        self.tableView.rx
            .itemSelected
            .bind {
                if let cell = self.tableView.cellForRow(at: $0) as? PostPreviewCell {
                    let vc = PostViewController()
                    vc.postInfo = (id: cell.postModel.value!._id!, type: cell.postModel.value!.boardType)
                    vc.postCell = cell
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        // inputs
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .bind { self.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?
            .rx.tap
            .bind {
                let vc = NewPostViewController()
                Constants.currentBoard = self.boardType
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Table view data source, delegate
extension PostListViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
