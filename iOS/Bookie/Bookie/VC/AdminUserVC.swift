//
//  AdminUserVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit


class UserHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userIdTextField: UILabel!
    @IBOutlet weak var userNameTextField: UILabel!
    @IBOutlet weak var statusTextField: UILabel!
    
}

class AdminUserVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlines.count
    }
    

    var headlines: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
            as! UserHeadlineTableViewCell
        
        let headline = headlines[indexPath.row]
        
        cell.userIdTextField.text = "#\(headline.userId)"
        cell.userNameTextField.text = headline.userName
        if headline.available {
            cell.statusTextField.text = "活跃"
        } else {
            cell.statusTextField.text = "已冻结"
        }
        return cell
    }

}
