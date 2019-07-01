//
//  PurchasedVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON


class BillHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var purchaseTimeField: UILabel!
    @IBOutlet weak var deliveryInfoField: UILabel!
    @IBOutlet weak var countField: UILabel!
}

class PurchasedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
    
    @IBOutlet weak var tableViewContent: UITableView!
    
    var headlines: [Bill] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadMyBills()
        tableViewContent.rowHeight = 88
        super.viewDidAppear(animated)
    }
    
    func refreshContent() {
        self.tableViewContent.reloadData()
    }
    
    func loadMyBills() {
        headlines.removeAll()
        refreshContent()
        Alamofire.request(BookieUri.myOrdersGetUri,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for billItem in jsonResp!["data"].arrayValue {
                                self.headlines.append(Bill(receiver: billItem["receiver"].stringValue,
                                                           flushId: billItem["billUuid"].stringValue,
                                                           phoneNo: billItem["phoneNo"].stringValue,
                                                           address: billItem["address"].stringValue,
                                                           purchasedTime: billItem["time"].stringValue))
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
                self.makeAlert("获取历史订单失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
            })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "billCell", for: indexPath)
            as! BillHeadlineTableViewCell
        
        let headline = headlines[indexPath.row]
        
        cell.titleTextField.text = "\(headline.receiver)"
        cell.authorTextField.text = "联系电话：\(headline.phoneNo)"
        cell.deliveryInfoField.text = "配送地址：\(headline.address)"
        cell.purchaseTimeField.text = "购买于 \(headline.purchasedTime)"
        cell.countField.text = "(收)"
        
        return cell
    }

}
