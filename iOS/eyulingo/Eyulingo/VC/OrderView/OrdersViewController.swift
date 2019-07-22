//
//  OrdersViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/22.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import Loaf
import SwiftyJSON
import UIKit

class OrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let constantCellsCount = 5

    @IBOutlet var ordersTableView: UITableView!
    @IBOutlet var orderTypePicker: UISegmentedControl!
    @IBOutlet var noContentIndicator: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    var loading = true

    func stopLoading() {
        let shouldShowNothing = currentFlag.rawValue >= combinedOrders.count || combinedOrders[currentFlag.rawValue].count == 0
        loading = false
        loadingIndicator.isHidden = true

        if shouldShowNothing {
            noContentIndicator.isHidden = false
            ordersTableView.isHidden = true
        } else {
            noContentIndicator.isHidden = true
            ordersTableView.isHidden = false
        }
    }

    func startLoading() {
        let shouldShowNothing = currentFlag.rawValue >= combinedOrders.count || combinedOrders[currentFlag.rawValue].count == 0
        loading = true
        loadingIndicator.isHidden = false
        noContentIndicator.isHidden = true
        if shouldShowNothing {
            ordersTableView.isHidden = true
        } else {
            ordersTableView.isHidden = false
        }
    }

    func judgeNoContentDisplay() {
        let shouldShowNothing = currentFlag.rawValue >= combinedOrders.count || combinedOrders[currentFlag.rawValue].count == 0
        if shouldShowNothing {
            noContentIndicator.isHidden = false
            ordersTableView.isHidden = true
        } else {
            noContentIndicator.isHidden = true
            ordersTableView.isHidden = false
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var defaultItemCount = constantCellsCount
        // receiver
        // receiver's phone
        // receiver's address
        // transporting method
        // create time

        if currentFlag.rawValue < combinedOrders.count {
            return (combinedOrders[currentFlag.rawValue][section].items?.count ?? 0) + constantCellsCount
        }
        return constantCellsCount
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "订单 #\(combinedOrders[currentFlag.rawValue][section].orderId ?? -1)"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if currentFlag.rawValue < combinedOrders.count {
            return combinedOrders[currentFlag.rawValue].count
        }
//        if currentFlag == OrderState.unpurchased {
//            return unpurchasedOrders.count
//        } else if currentFlag == OrderState.pending {
//            return pendingOrders.count
//        } else if currentFlag == OrderState.transporting {
//            return transportingOrders.count
//        } else if currentFlag == OrderState.received {
//            return receivedOrders.count
//        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersCell", for: indexPath)
        // receiver
        // receiver's phone
        // receiver's address
        // transporting method
        // create time
        let orderObject = combinedOrders[currentFlag.rawValue][indexPath.section]

        if indexPath.row == 0 {
            cell.textLabel?.text = "收件人"
            cell.detailTextLabel?.text = orderObject.receiver
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "联系电话"
            cell.detailTextLabel?.text = orderObject.receiverPhone
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "收件地址"
            cell.detailTextLabel?.text = orderObject.receiverAddress
        } else if indexPath.row == 3 {
            cell.textLabel?.text = "配送方式"
            cell.detailTextLabel?.text = orderObject.transportingMethod
        } else if indexPath.row == 4 {
            cell.textLabel?.text = "下单时间"
            cell.detailTextLabel?.text = "未知"
        } else {
            cell.textLabel?.text = "\(indexPath.row - constantCellsCount + 1) 号商品"
            cell.detailTextLabel?.text = combinedOrders[currentFlag.rawValue][indexPath.section].items?[indexPath.row - constantCellsCount].goodsName
        }
        return cell
    }

//    var unpurchasedOrders: [EyOrders] = []
//    var pendingOrders: [EyOrders] = []
//    var transportingOrders: [EyOrders] = []
//    var receivedOrders: [EyOrders] = []

    var combinedOrders: [[EyOrders]] = [[], [], [], []]

    var currentFlag: OrderState = .unpurchased

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadRawData()
    }

    @IBAction func orderTypePicked(_ sender: UISegmentedControl) {
        let newFlag = OrderState(rawValue: sender.selectedSegmentIndex) ?? OrderState.unpurchased
        if newFlag == currentFlag || currentFlag.rawValue >= combinedOrders.count {
            ordersTableView.reloadData()
            return
        }
        currentFlag = newFlag

//        CATransaction.begin()
//        ordersTableView.beginUpdates()
//        CATransaction.setCompletionBlock {
//            self.currentFlag = newFlag
//            self.loadRawData()
//        }
//
//
//        ordersTableView.deleteRows(at: toRemove, with: .fade)
//        ordersTableView.deleteSections(IndexSet(0 ..< combinedOrders[currentFlag.rawValue].count), with: .fade)
//        ordersTableView.endUpdates()
//        CATransaction.commit()
        ordersTableView.reloadData()
        judgeNoContentDisplay()
    }

    func loadRawData() {
        combinedOrders = [[], [], [], []]
        startLoading()
        var errorStr = "general error"
        Alamofire.request(Eyulingo_UserUri.purchasedGetUri,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for orderItem in jsonResp!["values"].arrayValue {
                                let orderStatus = orderItem["order_status"].stringValue
                                var orderStatusId = OrderState.unpurchased
                                if orderStatus == "unpurchased" {
                                    orderStatusId = OrderState.unpurchased
                                } else if orderStatus == "pending" {
                                    orderStatusId = OrderState.pending
                                } else if orderStatus == "transporting" {
                                    orderStatusId = OrderState.transporting
                                } else {
                                    orderStatusId = OrderState.received
                                }
                                var orderObject = EyOrders(orderId: orderItem["bill_id"].intValue,
                                                           receiver: orderItem["receiver"].stringValue,
                                                           receiverPhone: orderItem["receiver_phone"].stringValue,
                                                           receiverAddress: orderItem["receiver_address"].stringValue,
                                                           storeId: nil,
                                                           storeName: nil,
                                                           transportingMethod: orderItem["transport_method"].stringValue,
                                                           status: orderStatusId,
                                                           items: [])
                                for goodsItem in orderItem["goods"].arrayValue {
                                    let goodsObject = EyOrderItems(goodsId: goodsItem["id"].intValue,
                                                                   goodsName: goodsItem["name"].stringValue,
                                                                   storeId: goodsItem["store_id"].intValue,
                                                                   storeName: goodsItem["store"].stringValue,
                                                                   currentPrice: Decimal(string: goodsItem["current_price"].string ?? "0"),
                                                                   amount: goodsItem["amount"].intValue,
                                                                   description: goodsItem["description"].stringValue,
                                                                   imageId: goodsItem["image_id"].stringValue)
                                    orderObject.items!.append(goodsObject)
                                    if orderObject.storeName == nil || orderObject.storeId == nil {
                                        orderObject.storeName = goodsObject.storeName
                                        orderObject.storeId = goodsObject.storeId
                                    }
                                }
                                if orderObject.status?.rawValue ?? 4 < self.combinedOrders.count {
                                    self.combinedOrders[orderObject.status?.rawValue ?? 0].insert(orderObject, at: 0)
                                }
                            }
                            self.stopLoading()
                            self.orderTypePicked(self.orderTypePicker)
                            return
                        } else {
                            errorStr = jsonResp!["status"].stringValue
                        }
                    } else {
                        errorStr = "bad response"
                    }
                } else {
                    errorStr = "no response"
                }
                Loaf("加载订单失败。" + "服务器报告了一个 “\(errorStr)” 错误。", state: .error, sender: self).show()
                self.stopLoading()
            })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orderObject = combinedOrders[currentFlag.rawValue][indexPath.section]
        if currentFlag == OrderState.unpurchased {
            let alertController = UIAlertController(title: "想进行什么操作？",
                                                    message: "您刚刚选中了 “\(orderObject.storeName ?? "某")” 商店开具的 \(orderObject.orderId ?? -1) 号订单。",
                                                    preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)
            let removeOrder = UIAlertAction(title: "删除订单",
                                            style: .destructive,
                                            handler: { _ in

            })
            let payOrder = UIAlertAction(title: "付款",
                                         style: .default,
                                         handler: { _ in

            })
            alertController.addAction(cancelAction)
            alertController.addAction(payOrder)
            alertController.addAction(removeOrder)

            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
            }
            present(alertController, animated: true, completion: nil)
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
