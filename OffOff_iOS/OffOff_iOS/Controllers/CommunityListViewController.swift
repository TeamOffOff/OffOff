//
//  CommunityTableViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import UIKit

class CommunityListViewController: UITableViewController {

    override func loadView() {
        super.loadView()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(CommunityTableViewCell.classForCoder(), forCellReuseIdentifier: CommunityTableViewCell.identifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommunityTableViewCell.identifier, for: indexPath) as? CommunityTableViewCell else {
            return UITableViewCell()
        }
            
        cell.titleImage.image = data[indexPath.section][indexPath.row].image
        cell.titleLabel.text = data[indexPath.section][indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    // TODO: 선택한 게시판 정보 전달
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PostListViewController.embededController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class CommunityTableViewCell: UITableViewCell {
    var titleImage: UIImageView!
    var titleLabel: UILabel!
    static let identifier = "CommunityTableViewCell"
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        titleImage = UIImageView(image: UIImage(systemName: "cross"))
        titleLabel = UILabel().then {
            $0.text = "자유게시판"
            $0.textAlignment = .right
        }
        
        contentView.addSubview(titleImage)
        contentView.addSubview(titleLabel)
        
        titleImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(titleImage.snp.height)
        }
        titleLabel.snp.makeConstraints {
            $0.right.equalToSuperview().inset(12)
            $0.left.equalTo(titleImage.snp.right)
            $0.centerY.equalToSuperview()
        }
        
    }
}
