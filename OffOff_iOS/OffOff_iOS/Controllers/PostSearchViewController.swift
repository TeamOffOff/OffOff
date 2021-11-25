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
        
        // bind outputs
        viewModel!.searchedList
            .observe(on: MainScheduler.instance)
            .bind(to: customView.postListTableView.rx.items(cellIdentifier: PostPreviewCell.identifier, cellType: PostPreviewCell.self)) { (row, element, cell) in
                cell.postModel.accept(element)
            }
            .disposed(by: disposeBag)
    }
}
