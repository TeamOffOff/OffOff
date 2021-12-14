//
//  PostSearchViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/13.
//

import UIKit

import RxSwift
import RxCocoa

class PostSearchViewController: UIViewController {

    var boardType: String!
    
    let customView = PostSearchView()
    
    var disposeBag = DisposeBag()
    
    var viewModel: PostSearchViewModel!
    
    override func loadView() {
        self.view = customView
        
        self.customView.postListTableView.rowHeight = 81.adjustedHeight
        self.customView.postListTableView.separatorStyle = .none
        
        self.navigationItem.backButtonTitle = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = PostSearchViewModel(
            boardType: boardType,
            searchingText: self.customView.searchTextField.rx.text
                .orEmpty
                .distinctUntilChanged()
                .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
        )
        
        customView.postListTableView.rx
            .itemSelected
            .withUnretained(self)
            .bind { (owner, indexPath) in
                if let cell = owner.customView.postListTableView.cellForRow(at: indexPath) as? PostPreviewCell {
                    let vc = PostViewController()
                    vc.postInfo = (id: cell.postModel.value!._id!, type: cell.postModel.value!.boardType)
                    vc.title = "검색 결과"
                    vc.postCell = cell
                    owner.navigationController?.pushViewController(vc, animated: true)
                    owner.customView.postListTableView.deselectRow(at: indexPath, animated: false)
                }
            }
            .disposed(by: disposeBag)
        
        // bind outputs
        viewModel!.searchedList
            .observe(on: MainScheduler.instance)
            .bind(to: customView.postListTableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.postModel.accept(element)
            }
            .disposed(by: disposeBag)
    }
}
