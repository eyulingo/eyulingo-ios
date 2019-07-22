//
//  GoodsDetailTableViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/17.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import Loaf
import SwiftyJSON
import UIKit

class GoodsDetailTableViewController: UITableViewController, CartRefreshDelegate {
    func refreshCart() {
//        dismiss(animated: true, completion: nil)
        reloadStorage()
    }

    var openedByStoreId: Int?

    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: completion)
    }

    func reloadStorage() {
        var errorStr = "general error"
        let reloadGoodsId = goodsObject?.goodsId
        if reloadGoodsId == nil {
            return
        }
        let getParams: Parameters = [
            "id": reloadGoodsId!,
        ]
        Alamofire.request(Eyulingo_UserUri.goodDetailGetUri,
                          method: .get, parameters: getParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            self.goodsObject?.storage = jsonResp!["storage"].intValue
//                            self.goodsObject?.price = Decimal(string: jsonResp!["price"].string ?? "0")
//                            self.goodsObject?.couponPrice = Decimal(string: jsonResp!["coupon_price"].string ?? "0")
                            
                            self.stepper.stepValue = 1.0
                            self.stepper.minimumValue = 0.0
                            if self.goodsObject != nil {
                                self.stepper.maximumValue = Double(self.goodsObject!.storage!)
                            } else {
                                self.stepper.maximumValue = 1000.0
                            }
                            self.stepper.value = min(1.0, self.stepper.maximumValue)

                            self.goodsName.text = self.goodsObject?.goodsName
                            self.storeName.text = self.goodsObject?.storeName
                            self.priceField.text = "¥" + (self.goodsObject?.price?.formattedAmount ?? "未知")
                            self.descriptionField.text = self.goodsObject?.description
                            self.storageField.text = "\(self.goodsObject?.storage ?? 0) 件"
                            self.stepperChanged(self.stepper)
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
                Loaf("刷新库存失败。" + "服务器报告了一个 “\(errorStr)” 错误。", state: .error, sender: self).show()
            })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        stepper.stepValue = 1.0
        stepper.minimumValue = 0.0
        if goodsObject != nil {
            stepper.maximumValue = Double(goodsObject!.storage!)
        } else {
            stepper.maximumValue = 1000.0
        }
        stepper.value = min(1.0, stepper.maximumValue)

        goodsName.text = goodsObject?.goodsName
        storeName.text = goodsObject?.storeName
        priceField.text = "¥" + (goodsObject?.price?.formattedAmount ?? "未知")
        descriptionField.text = goodsObject?.description
        storageField.text = "\(goodsObject?.storage ?? 0) 件"
        stepperChanged(stepper)
        reloadStorage()
    }

    @IBAction func stepperChanged(_ sender: UIStepper) {
        amountField.text = "\(Int(sender.value)) 件"
        quantity = Int(sender.value)
    }

    @IBOutlet var goodsName: UILabel!
    @IBOutlet var storeName: UILabel!
    @IBOutlet var priceField: UILabel!
    @IBOutlet var descriptionField: UILabel!
    @IBOutlet var storageField: UILabel!
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var amountField: UILabel!

    var goodsObject: EyGoods?
    var quantity: Int = 0
    var delegate: DismissMyselfDelegate?
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func addToCartButtonTapped(_ sender: UIButton) {
        if quantity == 0 {
            return
        }
        if goodsObject == nil {
            return
        }

        let postParams: Parameters = [
            "id": goodsObject!.goodsId!,
            "amount": quantity,
        ]
        Alamofire.request(Eyulingo_UserUri.addToCartPostUri,
                          method: .post,
                          parameters: postParams,
                          encoding: JSONEncoding.default)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            CartRefreshManager.setModifiedState()
                            Loaf("成功将 \(self.quantity) 件 “\(self.goodsObject?.goodsName ?? "商品")” 加入购物车。", state: .success, sender: self).show()
                            return
                        } else {
                            errCode = jsonResp!["status"].stringValue
                        }
                    } else {
                        errCode = "bad response"
                    }
                } else {
                    errCode = "no response"
                }

                Loaf("加入购物车失败。" + "服务器报告了一个 “\(errCode)” 错误。", state: .error, sender: self).show()
            })
    }

    @IBAction func purchaseButtonTapped(_ sender: UIButton) {
        if quantity == 0 {
            return
        }
        if goodsObject == nil {
            return
        }
        var receiveAddresses: [ReceiveAddress] = []
        Alamofire.request(Eyulingo_UserUri.addressGetUri,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = ""
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for addressItem in jsonResp!["values"].arrayValue {
                                receiveAddresses.append(ReceiveAddress(receiver: addressItem["receive_name"].stringValue,
                                                                       phoneNo: addressItem["receive_phone"].stringValue,
                                                                       address: addressItem["receive_address"].stringValue))
                            }
                        } else {
                            errorCode = jsonResp!["status"].stringValue
                        }
                    } else {
                        errorCode = "bad response"
                    }
                } else {
                    errorCode = "no response"
                }
                //                if errorCode != "" {
                //                    Loaf("加载常用地址失败。服务器报告了一个 “\(errorCode)” 错误。", state: .error, sender: self).show()
                //                }

                let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "PurchaseVC") as! PurchaseViewController

                destinationViewController.possibleAddresses = receiveAddresses
//                        destinationViewController.delegate = self
                destinationViewController.toPurchaseGoods = [EyCarts(goodsId: self.goodsObject?.goodsId,
                                                                     goodsName: self.goodsObject?.goodsName,
                                                                     coverId: self.goodsObject?.coverId,
                                                                     storeId: self.goodsObject?.storeId,
                                                                     amount: self.quantity,
                                                                     storeName: self.goodsObject?.storeName,
                                                                     storage: self.goodsObject?.storage,
                                                                     price: self.goodsObject?.couponPrice,
                                                                     imageCache: nil)]
                destinationViewController.refreshDelegate = self
                self.present(destinationViewController, animated: true, completion: nil)
            })

        /*
         if !cartTableView.isEditing {
             quitEditMode()
             return
         }
         let postParams: Parameters = [

         ]
         Alamofire.request(Eyulingo_UserUri.purchasePostUri,
                           method: .post,
                           parameters: postParams,
                           encoding: JSONEncoding.default)
             .responseSwiftyJSON(completionHandler: { responseJSON in
                 var errCode = "general error"
                 if responseJSON.error == nil {
                     let jsonResp = responseJSON.value
                     if jsonResp != nil {
                         if jsonResp!["status"].stringValue == "ok" {
                             CartRefreshManager.setModifiedState()

                             return
                         } else {
                             errCode = jsonResp!["status"].stringValue
                         }
                     } else {
                         errCode = "bad response"
                     }
                 } else {
                     errCode = "no response"
                 }

                 Loaf("加入购物车失败。" + "服务器报告了一个 “\(errCode)” 错误。", state: .error, sender: self).show()
             })
         */
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */

    // Tap on table Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.becomeFirstResponder()
                let copyItem = UIMenuItem(title: "拷贝", action: #selector(copyGoodsName))
                let menuController = UIMenuController.shared
                menuController.menuItems = [copyItem]
                menuController.setTargetRect(cell.frame, in: cell.superview!)
                menuController.setMenuVisible(true, animated: true)
            }
        } else if indexPath.row == 1 {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.becomeFirstResponder()
                let visitItem = UIMenuItem(title: "造访", action: #selector(visitStore))
                let copyItem = UIMenuItem(title: "拷贝", action: #selector(copyStoreName))
                let menuController = UIMenuController.shared
                menuController.menuItems = [copyItem, visitItem]
                menuController.setTargetRect(cell.frame, in: cell.superview!)
                menuController.setMenuVisible(true, animated: true)
            }
        }
    }

    @objc func copyStoreName() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = goodsObject?.storeName
    }

    @objc func copyGoodsName() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = goodsObject?.goodsName
    }

    @objc func visitStore() {
        let storeId = goodsObject?.storeId!
        if storeId == openedByStoreId {
            delegate?.dismissMe()
            return
        }
        var errorStr = "general error"
        let getParams: Parameters = [
            "id": storeId!,
        ]
        Alamofire.request(Eyulingo_UserUri.storeDetailGetUri,
                          method: .get, parameters: getParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            var storeObject = EyStore(storeId: jsonResp!["id"].intValue,
                                                      coverId: jsonResp!["image_id"].stringValue,
                                                      storeName: jsonResp!["name"].stringValue,
                                                      storePhone: jsonResp!["phone_nu"].stringValue,
                                                      storeAddress: jsonResp!["address"].stringValue,
                                                      storeGoods: [],
                                                      storeComments: [],
                                                      distAvatarId: jsonResp!["provider_avatar"].stringValue,
                                                      distName: jsonResp!["provider"].stringValue)
                            for goodsItem in jsonResp!["values"].arrayValue {
                                let goodObject = EyGoods(goodsId: goodsItem["id"].intValue,
                                                         goodsName: goodsItem["name"].stringValue,
                                                         coverId: goodsItem["image_id"].stringValue,
                                                         description: goodsItem["description"].stringValue,
                                                         storeId: storeObject.storeId,
                                                         storeName: storeObject.storeName,
                                                         storage: goodsItem["storage"].intValue,
                                                         price: Decimal(string: goodsItem["price"].stringValue),
                                                         couponPrice: Decimal(string: goodsItem["coupon_price"].stringValue),
                                                         tags: [],
                                                         comments: [],
                                                         imageCache: nil)
                                storeObject.storeGoods?.append(goodObject)
                            }

                            for _ in jsonResp!["comments"].arrayValue {
                                // read comments
                            }

                            let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "StoreDetailVC") as! StoreDetailViewController

                            destinationViewController.storeObject = storeObject
                            destinationViewController.openedByGoodsId = self.goodsObject?.goodsId
                            self.present(destinationViewController, animated: true, completion: nil)
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
            })
        NSLog("request ended with " + errorStr)
    }
}

protocol DismissMyselfDelegate {
    func dismissMe() -> Void
}

extension UITableViewCell {
    open override var canBecomeFirstResponder: Bool {
        return true
    }
}
