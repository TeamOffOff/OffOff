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
            .do(onNext: { _ in refreshControl.endRefreshing() })
            .bind(to: self.tableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.titleLabel.text = element.title
                cell.dateAuthorLabel.text = "\(element.date) | \(element.author.nickname)"
                cell.previewTextView.text = element.content
                cell.likeLabel.label.text = "\(element.likes) "
                cell.commentLabel.label.text = "\(element.replyCount)"
            }
            .disposed(by: disposeBag)
        
        
        refreshControl.rx.controlEvent(.valueChanged)
                    .bind(to: viewModel!.reloadTrigger)
                    .disposed(by: disposeBag)

        // select row
        self.tableView.rx
            .modelSelected(PostModel.self)
            .bind {
                let vc = PostViewController()
                vc.postInfo = (id: $0._id!, type: $0.boardType)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        // inputs
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .bind { self.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?
            .rx.tap
            .bind { self.navigationController?.pushViewController(NewPostViewController(), animated: true) }
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
