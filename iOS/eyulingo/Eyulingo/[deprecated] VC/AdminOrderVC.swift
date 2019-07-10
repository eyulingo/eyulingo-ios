//
//  AdminOrderVC.swift
//  Eyulingo
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
    
    var sortedBillDict = [String: [AdminBill]]()
    var indexArray = [String]()
    
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
    
    func refreshContent() {
        orderTableView.reloadData()
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        Alamofire.request(BookieUri.logOutPostUri, method: .post).response(completionHandler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBOutlet weak var orderTableView: UITableView!
    
    var headlines: [AdminBill] = []
    
    var isbns: [String] = []
    var userIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        overrideUserInterfaceStyle = .dark
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAllOrder()
    }
    
    func buildDictionary() {
        
        indexArray.removeAll()
        sortedBillDict.removeAll()
        
        for bill in headlines {
            let result = "\(bill.userId)"
            
            if !indexArray.contains(result) {
                indexArray.append(result)
                indexArray.sort()
            }
            
            if sortedBillDict[result] == nil {
                sortedBillDict[result] = [bill]
            } else {
                if !sortedBillDict[result]!.contains(where: {
                    return $0.timeStamp == bill.timeStamp && $0.userId == bill.userId && $0.bookIsbn == bill.bookIsbn
                }) {
                    sortedBillDict[result]!.append(bill)
                    sortedBillDict[result]!.sort(by: {$0.bookIsbn < $1.bookIsbn} )
                }
            }
        }
        refreshContent()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexArray.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexArray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "用户 #\(indexArray[section]) 的 \(sortedBillDict[indexArray[section]]?.count ?? 0) 笔订单"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
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
                            self.buildDictionary()
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
        
        let headline = sortedBillDict[indexArray[indexPath.section]]![indexPath.row]
        
        cell.titleTextField.text = "ISBN: \(headline.bookIsbn)"
        cell.deliveryInfoField.text = "用户名：\(headline.userName)"
        cell.authorTextField.text = ""
        cell.purchaseTimeField.text = "购买于 \(DateAndTimeParser.parseDateAndTimeString(headline.timeStamp))"
        cell.countField.text = "×\(headline.count)"
        
        return cell
    }
    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let billObject = sortedBillDict[indexArray[indexPath.section]]![indexPath.row]
        
        let alertController = UIAlertController(title: "想进行什么操作？",
                                                message: "您刚刚选定了 \(billObject.userName) 的一笔订单。",
            preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        let seeBookSellingInfo = UIAlertAction(title: "查看该书籍销售情况",
                                               style: .default,
                                               handler: { _ in
                                                var log: String = ""
                                                var counter: Int = 0
                                                for bill in self.headlines {
                                                    if bill.bookIsbn == billObject.bookIsbn {
                                                        counter += bill.count
                                                        log += "\n\(DateAndTimeParser.parseDateAndTimeString(bill.timeStamp))\n#\(bill.userId) \(bill.userName) 购买了 \(bill.count) 册。\n"
                                                    }
                                                }
                                                self.makeAlert("此图书共售出 \(counter) 册。", log, completion: { })
        })
        
        let seeThatDayAllData = UIAlertAction(title: "查看当天全部订单",
                                               style: .default,
                                               handler: { _ in
                                                var log: String = ""
                                                var counter: Int = 0
                                                for bill in self.headlines {
                                                    if DateAndTimeParser.parseDayFromString(bill.timeStamp) == DateAndTimeParser.parseDayFromString(billObject.timeStamp) {
                                                        counter += bill.count
                                                        log += "\n\(DateAndTimeParser.parseDateAndTimeString(bill.timeStamp))\n#\(bill.userId) \(bill.userName) 购买了 \(bill.count) 册。\n"
                                                    }
                                                }
                                                self.makeAlert("\(DateAndTimeParser.parseDayFromString(billObject.timeStamp)) 共售出图书 \(counter) 册。", log, completion: { })
        })
        alertController.addAction(cancelAction)
        alertController.addAction(seeBookSellingInfo)
        alertController.addAction(seeThatDayAllData)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
