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
import MapKit

class OrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentsRefreshDelegate {
    func refreshComments() {
        loadRawData()
    }

    let constantCellsCount = 6

    @IBOutlet var ordersTableView: UITableView!
    @IBOutlet var orderTypePicker: UISegmentedControl!
    @IBOutlet var noContentIndicator: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    var loading = false

    func stopLoading() {
        let shouldShowNothing = currentFlag.rawValue >= combinedOrders.count || combinedOrders[currentFlag.rawValue].count == 0
        loading = false
        loadingIndicator.alpha = 1.0
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            self.loadingIndicator.alpha = 0.0
        }, completion: { _ in
            self.loadingIndicator.isHidden = true
            self.loadingIndicator.alpha = 1.0
        })

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
        loadingIndicator.alpha = 1.0
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

    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }

    func makePayment(orderId: Int) {
        let paramIds: [Parameters] = [[
            "order_id": orderId,
        ]]
        let postParams: Parameters = [
            "order_id": paramIds,
        ]

        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        loadingAlert.view.addSubview(loadingIndicator)

        present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.payPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                loadingAlert.dismiss(animated: true, completion: {
                                    self.makeAlert("成功", "您已成功支付订单。", completion: {
                                        self.loadRawData()
                                    })
                                })
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
                    Loaf("支付失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
                    self.loadRawData()
                })
        })
    }

    func removeOrder(orderId: Int) {
        let postParams: Parameters = [
            "order_id": orderId,
        ]

        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        loadingAlert.view.addSubview(loadingIndicator)

        present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.removeOrderPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                loadingAlert.dismiss(animated: true, completion: {
                                    Loaf("已成功删除该订单。", state: .success, sender: self).show()
                                    self.loadRawData()
                                })
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
                    Loaf("删除订单失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
                    self.loadRawData()
                })
        })
    }

    func confirmReceived(orderId: Int) {
        let postParams: Parameters = [
            "order_id": orderId,
        ]

        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        loadingAlert.view.addSubview(loadingIndicator)

        present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.confirmBillPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                loadingAlert.dismiss(animated: true, completion: {
                                    Loaf("已成功确认收货。", state: .success, sender: self).show()
                                    self.loadRawData()
                                })
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
                    loadingAlert.dismiss(animated: true, completion: {
                        Loaf("确认收货失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
                    })
                    self.loadRawData()
                })
        })
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersCell", for: indexPath)
        // receiver
        // receiver's phone
        // receiver's address
        // transporting method
        // create time
        let orderObject = combinedOrders[currentFlag.rawValue][indexPath.section]

        if currentFlag == .pending {
            if indexPath.row == 0 {
                cell.textLabel?.text = "收件人"
                cell.detailTextLabel?.text = orderObject.receiver
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "联系电话"
                cell.detailTextLabel?.text = orderObject.receiverPhone
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "收件地址"
                cell.detailTextLabel?.text = orderObject.receiverAddress
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 3 {
                cell.textLabel?.text = "配送方式"
                cell.detailTextLabel?.text = orderObject.transportingMethod
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 4 {
                cell.textLabel?.text = "总金额"
                cell.detailTextLabel?.text = "¥" + (orderObject.calculatePrice().formattedAmount ?? "0.00")
                cell.detailTextLabel?.textColor = UIColor(red: 1.0, green: 0.44, blue: 0.31, alpha: 1.0)
            } else if indexPath.row == 5 {
                cell.textLabel?.text = "下单时间"
                cell.detailTextLabel?.text = orderObject.createTime
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else {
                let goodsObject = combinedOrders[currentFlag.rawValue][indexPath.section].items?[indexPath.row - constantCellsCount]
                cell.textLabel?.text = "\(indexPath.row - constantCellsCount + 1) 号商品"
                cell.detailTextLabel?.text = "“\(goodsObject?.goodsName ?? "某商品")” \(goodsObject?.amount ?? 0) 件"
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            }
        } else if currentFlag == .transporting {
            if indexPath.row == 0 {
                cell.textLabel?.text = "收件人"
                cell.detailTextLabel?.text = orderObject.receiver
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "联系电话"
                cell.detailTextLabel?.text = orderObject.receiverPhone
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "收件地址"
                cell.detailTextLabel?.text = orderObject.receiverAddress
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 3 {
                cell.textLabel?.text = "配送方式"
                cell.detailTextLabel?.text = orderObject.transportingMethod
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 4 {
                cell.textLabel?.text = "总金额"
                cell.detailTextLabel?.text = "¥" + (orderObject.calculatePrice().formattedAmount ?? "0.00")
                cell.detailTextLabel?.textColor = UIColor(red: 1.0, green: 0.44, blue: 0.31, alpha: 1.0)
            } else if indexPath.row == 5 {
                cell.textLabel?.text = "操作"
                cell.detailTextLabel?.text = "确认收货"
                cell.detailTextLabel?.textColor = UIColor.systemBlue
            } else {
                let goodsObject = combinedOrders[currentFlag.rawValue][indexPath.section].items?[indexPath.row - constantCellsCount]
                cell.textLabel?.text = "\(indexPath.row - constantCellsCount + 1) 号商品"
                cell.detailTextLabel?.text = "“\(goodsObject?.goodsName ?? "某商品")” \(goodsObject?.amount ?? 0) 件"
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            }
        } else if currentFlag == .unpurchased {
            if indexPath.row == 0 {
                cell.textLabel?.text = "收件人"
                cell.detailTextLabel?.text = orderObject.receiver
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "联系电话"
                cell.detailTextLabel?.text = orderObject.receiverPhone
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "收件地址"
                cell.detailTextLabel?.text = orderObject.receiverAddress
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 3 {
                cell.textLabel?.text = "配送方式"
                cell.detailTextLabel?.text = orderObject.transportingMethod
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 4 {
                cell.textLabel?.text = "总金额"
                cell.detailTextLabel?.text = "¥" + (orderObject.calculatePrice().formattedAmount ?? "0.00")
                cell.detailTextLabel?.textColor = UIColor(red: 1.0, green: 0.44, blue: 0.31, alpha: 1.0)
            } else if indexPath.row == 5 {
                cell.textLabel?.text = "操作"
                cell.detailTextLabel?.text = "处理订单"
                cell.detailTextLabel?.textColor = UIColor.systemBlue
            } else {
                let goodsObject = combinedOrders[currentFlag.rawValue][indexPath.section].items?[indexPath.row - constantCellsCount]
                cell.textLabel?.text = "\(indexPath.row - constantCellsCount + 1) 号商品"
                cell.detailTextLabel?.text = "“\(goodsObject?.goodsName ?? "某商品")” \(goodsObject?.amount ?? 0) 件"
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            }
        } else if currentFlag == .received {
            if indexPath.row == 0 {
                cell.textLabel?.text = "收件人"
                cell.detailTextLabel?.text = orderObject.receiver
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "联系电话"
                cell.detailTextLabel?.text = orderObject.receiverPhone
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "收件地址"
                cell.detailTextLabel?.text = orderObject.receiverAddress
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 3 {
                cell.textLabel?.text = "配送方式"
                cell.detailTextLabel?.text = orderObject.transportingMethod
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            } else if indexPath.row == 4 {
                cell.textLabel?.text = "总金额"
                cell.detailTextLabel?.text = "¥" + (orderObject.calculatePrice().formattedAmount ?? "0.00")
                cell.detailTextLabel?.textColor = UIColor(red: 1.0, green: 0.44, blue: 0.31, alpha: 1.0)
            } else if indexPath.row == 5 {
                if orderObject.rated ?? false {
                    cell.textLabel?.text = "订单评价"
                    cell.detailTextLabel?.text = "\(StarVisualizer.getStarsText(orderObject.rateLevel ?? 5))"
                    cell.detailTextLabel?.textColor = UIColor.systemBlue
                } else {
                    cell.textLabel?.text = "订单评价"
                    cell.detailTextLabel?.text = "立即评价"
                    cell.detailTextLabel?.textColor = UIColor.systemBlue
                }
            } else {
                let goodsObject = combinedOrders[currentFlag.rawValue][indexPath.section].items?[indexPath.row - constantCellsCount]
                cell.textLabel?.text = "\(indexPath.row - constantCellsCount + 1) 号商品"
                cell.detailTextLabel?.text = "“\(goodsObject?.goodsName ?? "某商品")” \(goodsObject?.amount ?? 0) 件"
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = UIColor.label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            }
        }
        return cell
    }

//    var unpurchasedOrders: [EyOrders] = []
//    var pendingOrders: [EyOrders] = []
//    var transportingOrders: [EyOrders] = []
//    var receivedOrders: [EyOrders] = []

    var combinedOrders: [[EyOrders]] = [[], [], [], []]

    var currentFlag: OrderState = .unpurchased
    
    var currentLocation: CLLocationCoordinate2D?
    
    var targetDescription: String = "配送位置"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

//        loadRawData()
        ordersTableView.addPullToRefreshWithAction {
            self.loadRawData(completion: {
                self.ordersTableView.stopPullToRefresh()
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

    func loadRawData(completion: (() -> Void)? = nil) {
        if loading {
            return
        }
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
                                                           items: [],
                                                           createTime: DateAndTimeParser.parseDateAndTimeString(orderItem["generate_time"].stringValue),
                                                           rated: orderItem["rated"].boolValue,
                                                           rateLevel: orderItem["star_count"].intValue,
                                                           commentContent: orderItem["comment_content"].stringValue,
                                                           location: CLLocationCoordinate2D(latitude: orderItem["latitude"].doubleValue,
                                                                                            longitude: orderItem["longitude"].doubleValue))
                                for goodsItem in orderItem["goods"].arrayValue {
                                    let goodsObject = EyOrderItems(goodsId: goodsItem["id"].intValue,
                                                                   goodsName: goodsItem["name"].stringValue,
                                                                   storeId: goodsItem["store_id"].intValue,
                                                                   storeName: goodsItem["store"].stringValue,
                                                                   currentPrice: Decimal(string: goodsItem["current_price"].stringValue),
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
                                    self.combinedOrders[orderObject.status?.rawValue ?? 0].append(orderObject)
                                }
                            }
                            self.stopLoading()
                            self.orderTypePicked(self.orderTypePicker)
                            completion?()
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
                completion?()
            })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orderObject = combinedOrders[currentFlag.rawValue][indexPath.section]
        if currentFlag == OrderState.unpurchased && indexPath.row == 5 {
            let alertController = UIAlertController(title: "想进行什么操作？",
                                                    message: "您刚刚选中了 “\(orderObject.storeName ?? "某商店")” 开具的 \(orderObject.orderId ?? -1) 号订单。",
                                                    preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)
            let removeOrder = UIAlertAction(title: "放弃订单",
                                            style: .destructive,
                                            handler: { _ in
                                                self.removeOrder(orderId: orderObject.orderId!)
            })
            let payOrder = UIAlertAction(title: "付款",
                                         style: .default,
                                         handler: { _ in
                                             if orderObject.orderId == nil {
                                                 return
                                             }
                                             self.makePayment(orderId: orderObject.orderId!)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(payOrder)
            alertController.addAction(removeOrder)

            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
            }
            present(alertController, animated: true, completion: nil)
        } else if currentFlag == OrderState.received && indexPath.row == 5 {
            if orderObject.rated ?? false {
                makeAlert("您对此订单的评价", "\(StarVisualizer.getStarsText(orderObject.rateLevel ?? 5))\n" +
                    "\(orderObject.commentContent ?? "无评价内容。")", completion: {})
            } else {
                let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "SubmitCommentsVC") as! SubmitCommentsViewController
                destinationViewController.commentType = CommentType.ordersComments
                destinationViewController.ordersId = orderObject.orderId
                destinationViewController.delegate = self
                present(destinationViewController, animated: true, completion: nil)
            }
        } else if currentFlag == OrderState.transporting && indexPath.row == 2 {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.becomeFirstResponder()
                activeIndexPath = indexPath
                currentLocation = orderObject.location
                targetDescription = "\(orderObject.orderId ?? 0) 号订单当前位置"
                let copyItem = UIMenuItem(title: "拷贝", action: #selector(copyValidInfo))
                let showDistance = UIMenuItem(title: "显示距离", action: #selector(showDistanceFunction))
                let menuController = UIMenuController.shared
                menuController.menuItems = [copyItem, showDistance]
//                menuController.setTargetRect(cell.frame, in: cell.superview!)
//                menuController.setMenuVisible(true, animated: true)
//
                menuController.showMenu(from: cell.superview!, rect: cell.frame)
            }
        } else if currentFlag == OrderState.transporting && indexPath.row == 5 {
            let alertController = UIAlertController(title: "您确定已经收到了这笔订单吗？",
                                                    message: "您刚刚选中了 “\(orderObject.storeName ?? "某商店")” 开具的 \(orderObject.orderId ?? -1) 号订单。",
                                                    preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)

            let confirmReceived = UIAlertAction(title: "确定",
                                                style: .default,
                                                handler: { _ in
                                                    if orderObject.orderId == nil {
                                                        return
                                                    }
                                                    self.confirmReceived(orderId: orderObject.orderId!)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(confirmReceived)
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
            }
            present(alertController, animated: true, completion: nil)
        } else {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.becomeFirstResponder()
                activeIndexPath = indexPath
                let copyItem = UIMenuItem(title: "拷贝", action: #selector(copyValidInfo))
                let menuController = UIMenuController.shared
                menuController.menuItems = [copyItem]
                menuController.setTargetRect(cell.frame, in: cell.superview!)
                menuController.setMenuVisible(true, animated: true)
            }
        }
    }

    @objc func copyValidInfo() {
        if activeIndexPath != nil
            && activeIndexPath!.section < ordersTableView.numberOfSections
            && activeIndexPath!.row < ordersTableView.numberOfRows(inSection: activeIndexPath!.section) {
            let pasteboard = UIPasteboard.general
            let cell = ordersTableView.cellForRow(at: activeIndexPath!)
            pasteboard.string = "\(cell?.textLabel?.text ?? "属性名称") \(cell?.detailTextLabel?.text ?? "属性值")"

        } else {
            activeIndexPath = nil
        }
    }
    
    @objc func showDistanceFunction() {
        if currentLocation != nil {
            /*
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.lat.floatValue, self.lon.floatValue) addressDictionary:nil]]; //目的地坐标
            toLocation.name = self.destination; //目的地名字
            [toLocation openInMapsWithLaunchOptions:nil];
            */
            
            let currentLocationItem = MKMapItem.forCurrentLocation()
            let toLocationItem = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation!, addressDictionary: nil))
            
            toLocationItem.name = targetDescription
            toLocationItem.openInMaps(launchOptions: nil)
        }
    }

    var activeIndexPath: IndexPath?
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
