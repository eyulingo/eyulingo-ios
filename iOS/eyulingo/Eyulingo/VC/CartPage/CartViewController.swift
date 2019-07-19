//
//  CartViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/9.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import Loaf
import Refresher
import SwiftyJSON
import UIKit

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CartRefreshDelegate, AmountModifyDelegate {
    func refreshCart() {
        constructData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goodsInCart[section].1.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cartObject = goodsInCart[indexPath.section].1[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "CartGoodsCell", for: indexPath) as! GoodsInCartTableCell
        cell.goodsNameField.text = cartObject.goodsName ?? "商品名称"
        cell.priceField.text = cartObject.price?.formattedAmount ?? "未知"
        cell.amountField.text = "×\(cartObject.amount ?? 0)"
        cell.storeField.text = "库存 \(cartObject.storage ?? 0) 件"
        cell.inadequatePromptField.isHidden = cartObject.amount ?? -1 < cartObject.storage ?? 1
        cell.amountModifyDelegate = self
        cell.amount = cartObject.amount ?? 0
        cell.goodsId = cartObject.goodsId
        cell.initCell()

        if cartObject.imageCache != nil {
            cell.imageViewField.image = cartObject.imageCache
            return cell
        }

        if cell.imageViewField.image == nil {
            cartObject.getCoverAsync(handler: { image in
                if cell.goodsNameField.text != cartObject.goodsName {
                    self.goodsInCart[indexPath.section].1[indexPath.row].imageCache = image
                    return
                }
                cell.fadeIn(image: image, handler: nil)
                self.goodsInCart[indexPath.section].1[indexPath.row].imageCache = image
            })
        } else {
            cell.fadeOut(handler: {
                cartObject.getCoverAsync(handler: { image in
                    if cell.goodsNameField.text != cartObject.goodsName {
                        self.goodsInCart[indexPath.section].1[indexPath.row].imageCache = image
                        return
                    }
                    cell.fadeIn(image: image, handler: nil)
                    self.goodsInCart[indexPath.section].1[indexPath.row].imageCache = image
                })
            })
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return goodsInCart.count
    }

//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return existedStores
//    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return existedStores[section]
    }

    func stopLoading() {
        loading = false
        loadingIndicator.isHidden = true
        if goodsInCart.count == 0 {
            noContentIndicator.isHidden = false
            cartTableView.isHidden = true
        } else {
            noContentIndicator.isHidden = true
            cartTableView.isHidden = false
        }
    }

    func startLoading() {
        loading = true
        loadingIndicator.isHidden = false
        noContentIndicator.isHidden = true
        if goodsInCart.count == 0 {
            noContentIndicator.isHidden = false
            cartTableView.isHidden = true
        } else {
            noContentIndicator.isHidden = true
            cartTableView.isHidden = false
        }
    }

    @IBOutlet var noContentIndicator: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var cartTableView: UITableView!

    var existedStores: [String] = []
    var goodsInCart: [(Int, [EyCarts])] = []
    var loading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
//        stopLoading()
        // Do any additional setup after loading the view.
//        constructData()
        cartTableView.addPullToRefreshWithAction {
            self.constructData(completion: {
                self.cartTableView.stopPullToRefresh()
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if !loading && CartRefreshManager.shouldCartRefresh() {
            constructData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cartObject = goodsInCart[indexPath.section].1[indexPath.row]
        openGoodsDetail(cartObject.goodsId!, imgCache: cartObject.imageCache)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cartId = goodsInCart[indexPath.section].1[indexPath.row].goodsId

        let cartName = goodsInCart[indexPath.section].1[indexPath.row].goodsName

        if cartId == nil || cartName == nil {
            return []
        }

        let detailAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "造访店铺") { _, _ in
            let cartObject = self.goodsInCart[indexPath.section].1[indexPath.row]
            self.visitStore(cartObject.storeId!)
        }

        detailAction.backgroundColor = .systemBlue

        // 删除
        let deleteAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "移除") { _, _ in

            let postParams: Parameters = [
                "id": cartId!,
            ]
            Alamofire.request(Eyulingo_UserUri.removeFromCartPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default
            ).responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            self.constructData()
                            Loaf("成功将 “\(cartName!)” 从购物车中移除。", state: .success, sender: self).show()
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
                Loaf("未能将 “\(cartName!)” 从购物车中移除。服务器报告了一个 “\(errorCode)” 错误", state: .error, sender: self).show()
            })
        }

        return [deleteAction, detailAction]
    }

    func constructData(completion: (() -> Void)? = nil) {
//        loading = true
        startLoading()
        var errorStr = "general error"

        Alamofire.request(Eyulingo_UserUri.myCartGetUri,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            let sectionCount = min(self.existedStores.count, self.goodsInCart.count)
                            CATransaction.begin()
                            self.cartTableView.beginUpdates()
                            CATransaction.setCompletionBlock {
                                for cartItem in jsonResp!["values"].arrayValue {
                                    let cartObject = EyCarts(goodsId: cartItem["id"].intValue,
                                                             goodsName: cartItem["name"].stringValue,
                                                             coverId: cartItem["image_id"].stringValue,
                                                             storeId: cartItem["store_id"].intValue,
                                                             amount: cartItem["amount"].intValue,
                                                             storeName: cartItem["store"].stringValue,
                                                             storage: cartItem["storage"].intValue,
                                                             price: Decimal(string: cartItem["price"].stringValue),
                                                             imageCache: nil)

                                    var counter = 0
                                    var flag = true
                                    for item in self.goodsInCart {
                                        if item.0 == cartObject.storeId {
                                            self.cartTableView.beginUpdates()
                                            self.goodsInCart[counter].1.append(cartObject)

                                            self.cartTableView.insertRows(at: [IndexPath(row: self.goodsInCart[counter].1.count - 1, section: counter)], with: .fade)
                                            self.cartTableView.endUpdates()
                                            flag = false
                                            break
                                        }
                                        counter += 1
                                    }
                                    if flag {
                                        self.cartTableView.beginUpdates()
                                        self.goodsInCart.append((cartObject.storeId!, [cartObject]))
                                        self.existedStores.append(cartObject.storeName!)

                                        let section = self.goodsInCart.count - 1
                                        self.cartTableView.insertSections(IndexSet(arrayLiteral: section), with: .fade)
                                        self.cartTableView.insertRows(at: [IndexPath(row: self.goodsInCart[section].1.count - 1, section: section)], with: .automatic)
                                        self.cartTableView.endUpdates()
                                    }
//                                    self.cartTableView.reloadData()
                                }
                                completion?()
                                self.stopLoading()
                            }
                            var toRemove: [IndexPath] = []
                            var i = 0
                            while i < self.goodsInCart.count {
                                var j = 0
                                while j < self.goodsInCart[i].1.count {
                                    toRemove.append(IndexPath(row: j, section: i))
                                    j += 1
                                }
                                i += 1
                            }

                            self.goodsInCart.removeAll()
                            self.existedStores.removeAll()

                            self.cartTableView.deleteRows(at: toRemove, with: .fade)
                            self.cartTableView.deleteSections(IndexSet(0 ..< sectionCount), with: .fade)
                            self.cartTableView.endUpdates()

                            CATransaction.commit()
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
                Loaf("加载购物车失败。" + "服务器报告了一个 “\(errorStr)” 错误。", state: .error, sender: self).show()
                completion?()
            })
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */

    // MARK: - Shared Page Controller

    func openGoodsDetail(_ goodsId: Int, imgCache: UIImage? = nil) {
        var errorStr = "general error"
        let getParams: Parameters = [
            "id": goodsId,
        ]
        Alamofire.request(Eyulingo_UserUri.goodDetailGetUri,
                          method: .get, parameters: getParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            let goodObj = EyGoods(goodsId: jsonResp!["id"].intValue,
                                                  goodsName: jsonResp!["name"].stringValue,
                                                  coverId: jsonResp!["image_id"].stringValue,
                                                  description: jsonResp!["description"].stringValue,
                                                  storeId: jsonResp!["store_id"].intValue,
                                                  storeName: jsonResp!["store"].stringValue,
                                                  storage: jsonResp!["storage"].intValue,
                                                  price: Decimal(string: jsonResp!["price"].stringValue),
                                                  couponPrice: Decimal(string: jsonResp!["coupon_price"].stringValue),
                                                  tags: [],
                                                  comments: [],
                                                  imageCache: imgCache)
                            for _ in jsonResp!["comments"].arrayValue {
                                // read comments
                            }

                            let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "GoodsDetailVC") as! GoodsDetailViewController

                            destinationViewController.goodsObject = goodObj
                            destinationViewController.refreshCartDelegate = self

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

    func visitStore(_ storeId: Int) {
        var errorStr = "general error"
        let getParams: Parameters = [
            "id": storeId,
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
//                            destinationViewController.openedByGoodsId = self.goodsObject?.goodsId
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

    func updateAmount(goodsId: Int?, quantity: Int, completion: (() -> Void)?) {
        if goodsId == nil {
            return
        }
        if quantity == 0 {
            return
        }

        let postParams: Parameters = [
            "id": goodsId!,
            "amount": quantity,
        ]
        Alamofire.request(Eyulingo_UserUri.modifyAmountFromCartPostUri,
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
                            completion?()
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

                Loaf("修改数量失败。" + "服务器报告了一个 “\(errCode)” 错误。", state: .error, sender: self).show()
                completion?()
            })
    }
}
