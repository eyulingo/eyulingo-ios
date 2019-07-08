//
//  PurchasedVC.swift
//  Eyulingo
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
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        Alamofire.request(EyulingoUri.logOutPostUri, method: .post).response(completionHandler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedBillDict[indexArray[section]]!.count
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
    var sortedBillDict = [String: [Bill]]()
    var indexArray = [String]()
    
    func buildIndex() {
        
        indexArray.removeAll()
        sortedBillDict.removeAll()
        
        for bill in headlines {
            
            let result = "\(DateAndTimeParser.parseDayFromString(bill.purchasedTime))"
            
            if !indexArray.contains(result) {
                indexArray.append(result)
                indexArray.sort()
            }
            
            if sortedBillDict[result] == nil {
                sortedBillDict[result] = [bill]
            } else {
                if !sortedBillDict[result]!.contains(where: {
                    return $0.flushId == bill.flushId
                }) {
                    sortedBillDict[result]!.append(bill)
                    sortedBillDict[result]!.sort(by: {$0.purchasedTime < $1.purchasedTime} )
                }
            }
        }
        refreshContent()
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexArray.count
    }
//
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return indexArray
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(indexArray[section]) 的 \(sortedBillDict[indexArray[section]]?.count ?? 0) 笔订单"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
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
        Alamofire.request(EyulingoUri.myOrdersGetUri,
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
                            self.buildIndex()
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
        
        let headline = sortedBillDict[indexArray[indexPath.section]]![indexPath.row]
        
        cell.titleTextField.text = "\(headline.receiver)"
        cell.authorTextField.text = "联系电话：\(headline.phoneNo)"
        cell.deliveryInfoField.text = "配送地址：\(headline.address)"
        cell.purchaseTimeField.text = "购买于 \(DateAndTimeParser.parseDateAndTimeString(headline.purchasedTime))"
        cell.countField.text = "(收)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let billObject = sortedBillDict[indexArray[indexPath.section]]![indexPath.row]
        
        let alertController = UIAlertController(title: "想进行什么操作？",
                                                message: "您刚刚选定了流水号为 \(billObject.flushId) 的订单。",
            preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        let seeBookSellingInfo = UIAlertAction(title: "查看所有配送给 “\(billObject.receiver)” 的订单",
                                               style: .default,
                                               handler: { _ in
                                                var log: String = ""
                                                var counter: Int = 0
                                                for bill in self.headlines {
                                                    if bill.receiver == billObject.receiver {
                                                        counter += 1
                                                        log += "\n\(DateAndTimeParser.parseDateAndTimeString(bill.purchasedTime))\n配送给 \(bill.address) \(bill.receiver)\n联系电话：\(bill.phoneNo)\n"
                                                    }
                                                }
                                                self.makeAlert("配送给 \(billObject.receiver) 的订单共计 \(counter) 笔。", log, completion: { })
        })
        alertController.addAction(cancelAction)
        alertController.addAction(seeBookSellingInfo)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

}
