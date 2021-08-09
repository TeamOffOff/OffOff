//
//  BoardListViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import UIKit
import RxSwift

class BoardListViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    
    override func loadView() {
        self.tableView = .init()
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidLoad() {
        let viewModel = BoardListViewModel()
        
        // bind result
        viewModel.boardLists
            .bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.name
                cell.imageView?.image = UIImage.init(systemName: "list.bullet")
            }
            .disposed(by: disposeBag)
        
        // row 선택 대응
        self.tableView.rx
            .modelSelected(Board.self)
            .subscribe(onNext: {
                let vc = PostListViewController()
                vc.boardType = $0.board_type
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
