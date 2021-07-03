//
//  CommunityTableViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import UIKit

class CommunityTableViewController: UITableViewController {

    override func loadView() {
        super.loadView()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.register(CommunityTableViewCell.classForCoder(), forCellReuseIdentifier: CommunityTableViewCell.identifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data[section].count
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        }
        titleLabel.snp.makeConstraints {
            $0.right.equalToSuperview().inset(12)
            $0.left.equalTo(titleImage.snp.right)
            $0.centerY.equalToSuperview()
        }
        
    }
}
