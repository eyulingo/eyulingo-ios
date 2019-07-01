//
//  AdminOrderVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class AdminBillHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var purchaseTimeField: UILabel!
    @IBOutlet weak var deliveryInfoField: UILabel!
    @IBOutlet weak var countField: UILabel!
}

class AdminOrderVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
    
    func refreshContent() {
        orderTableView.reloadData()
    }
    
    @IBOutlet weak var orderTableView: UITableView!
    
    var headlines: [AdminBill] = []
    
    var isbns: [String] = []
    var userIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAllOrder()
    }
    
    func loadAllOrder() {
        headlines.removeAll()
        refreshContent()
        Alamofire.request(BookieUri.adminGetAllBills,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for orderItem in jsonResp!["values"].arrayValue {
                                self.headlines.append(AdminBill(userId: orderItem["userId"].intValue,
                                                                userName: orderItem["userName"].stringValue,
                                                                bookIsbn: orderItem["bookIsbn"].stringValue,
                                                                count: orderItem["count"].intValue,
                                                                timeStamp: orderItem["timestamp"].stringValue))
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
                self.makeAlert("获取全部订单失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
            })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminBillCell", for: indexPath)
            as! AdminBillHeadlineTableViewCell
        
        let headline = headlines[indexPath.row]
        
        cell.titleTextField.text = "ISBN: \(headline.bookIsbn)"
        cell.deliveryInfoField.text = "用户 #\(headline.userId) \(headline.userName)"
        cell.authorTextField.text = ""
        cell.purchaseTimeField.text = "购买于 \(headline.timeStamp)"
        cell.countField.text = "×\(headline.count)"
        
        return cell
    }
}
