//
//  AdminUserVC.swift
//  Eyulingo
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

    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        Alamofire.request(BookieUri.logOutPostUri, method: .post).response(completionHandler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
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
//        overrideUserInterfaceStyle = .dark
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAllUser()
    }
    
    @IBOutlet weak var userTableView: UITableView!
    
    func refreshContent() {
        userTableView.reloadData()
    }
    
    func loadAllUser() {
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

    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userObject = headlines[indexPath.row]
        
        let alertController = UIAlertController(title: "想进行什么操作？",
                                                message: "您刚刚选定了 #\(userObject.userId) 号用户 \(userObject.userName)。",
            preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
    
        var activeAction: UIAlertAction?
        if userObject.available {
            activeAction = UIAlertAction(title: "冻结该用户",
                                         style: .destructive,
                                         handler: { _ in
                                            let postParams: Parameters = [
                                                "userId": userObject.userId
                                            ]
                Alamofire.request(BookieUri.disableUser,
                                  method: .post,
                                  parameters: postParams
                    ).responseSwiftyJSON(completionHandler: { responseJSON in
                        var errorCode = "general error"
                        if responseJSON.error == nil {
                            let jsonResp = responseJSON.value
                            if jsonResp != nil {
                                if jsonResp!["status"].stringValue == "ok" {
                                    self.makeAlert("成功", "成功冻结了此用户。", completion: {
                                        self.loadAllUser()
                                    })
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
                        self.makeAlert("冻结用户失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                    })
                })
        } else {
            activeAction = UIAlertAction(title: "解冻该用户",
                                         style: .destructive,
                                         handler: { _ in
                                            let postParams: Parameters = [
                                                "userId": userObject.userId
                                            ]
                                            Alamofire.request(BookieUri.enableUser,
                                                              method: .post,
                                                              parameters: postParams
                                                ).responseSwiftyJSON(completionHandler: { responseJSON in
                                                    var errorCode = "general error"
                                                    if responseJSON.error == nil {
                                                        let jsonResp = responseJSON.value
                                                        if jsonResp != nil {
                                                            if jsonResp!["status"].stringValue == "ok" {
                                                                self.makeAlert("成功", "成功解冻了此用户。", completion: {
                                                                    self.loadAllUser()
                                                                })
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
                                                    self.makeAlert("解冻用户失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                                                })
            })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(activeAction!)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
