//
//  GoodsDetailTableViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/17.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON
import Loaf

class GoodsDetailTableViewController: UITableViewController {
    
    var openedByStoreId: Int?

    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: nil)
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: completion)
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
    }
    
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        amountField.text = "\(Int(sender.value)) 件"
        quantity = Int(sender.value)
    }
    
    @IBOutlet weak var goodsName: UILabel!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var priceField: UILabel!
    @IBOutlet weak var descriptionField: UILabel!
    @IBOutlet weak var storageField: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var amountField: UILabel!
    
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
            "amount": quantity
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
            "id": storeId!
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
    func dismissMe() -> ()
}

extension UITableViewCell {
    override open var canBecomeFirstResponder: Bool {
        return true
    }
}
