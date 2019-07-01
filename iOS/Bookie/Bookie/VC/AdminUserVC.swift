//
//  AdminUserVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class UserHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userIdTextField: UILabel!
    @IBOutlet weak var userNameTextField: UILabel!
    @IBOutlet weak var statusTextField: UILabel!
    
}

class AdminUserVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlines.count
    }
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }

    var headlines: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var userTableView: UITableView!
    
    func refreshContent() {
        userTableView.reloadData()
    }
    
    func loadMyCart() {
        headlines.removeAll()
        refreshContent()
        Alamofire.request(BookieUri.adminGetAllUsers,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for userItem in jsonResp!["data"].arrayValue {
                                self.headlines.append(User(userId: userItem["id"].intValue,
                                                           userName: userItem["name"].stringValue,
                                                           available: userItem["available"].boolValue))
                                self.refreshContent()
                            }
                            return
                        } else {
                            errorCode = jsonResp!["status"].stringValue
                        }
                    } else {
                        errorCode = "bad response"
                    }
                } else {
                    errorCode = "no response"
                }
                self.makeAlert("获取用户列表失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
            })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminUserCell", for: indexPath)
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
