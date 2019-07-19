//
//  ResultTableView.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/17.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import Highlighter
import Refresher



class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, goToStoreDelegate {
    
    var delegate: RefreshDelegate?
    
    func goToStore(_ storeId: Int?) {
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        resultTable.addPullToRefreshWithAction {
            if self.delegate != nil {
                self.delegate?.callRefresh(handler: {
                    self.resultTable.stopPullToRefresh()
                })
            } else {
                self.resultTable.stopPullToRefresh()
            }
        }
    }
    
    @IBOutlet var resultTable: UITableView!
    var resultGoods: [EyGoods] = []
    
    var keyWord: String?
    
    func reloadData() {
        resultTable.reloadData()
    }
    
    // MARK: - delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let goodsObject = resultGoods[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultGoodsCell", for: indexPath) as! GoodsResultTableCell
        
//        tableView.register(GoodsResultTableCell.self, forCellReuseIdentifier: "ResultGoodsCell")
        // 判断系统版本，必须iOS 9及以上，同时检测是否支持触摸力度识别
//        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
//            // 注册预览代理，self监听，tableview执行Peek
//            registerForPreviewing(with: self, sourceView: tableView)
//        }
        
        cell.goodsNameField.text = goodsObject.goodsName ?? "商品名"
        cell.descriptionTextField.text = goodsObject.description ?? "商品描述"
        cell.priceTextField.text = "¥" + (goodsObject.price?.formattedAmount ?? "未知")
        cell.storageTextField.text = "库存 \(goodsObject.storage ?? 0) 件"
        cell.storeTextField.text = goodsObject.storeName ?? "店铺未知"
        cell.delegate = self
        
        if keyWord != nil {
            if #available(iOS 13.0, *) {
                cell.highlight(text: keyWord!, normal: nil, highlight: [NSAttributedString.Key.backgroundColor: UIColor.systemFill])
            } else {
                cell.highlight(text: keyWord!, normal: nil, highlight: [NSAttributedString.Key.backgroundColor: UIColor.darkGray])
            }
        }
        
        if goodsObject.imageCache != nil {
            cell.imageViewField.image = goodsObject.imageCache
            return cell
        }
        
        if cell.imageViewField.image == nil {
            goodsObject.getCoverAsync(handler: { image in
                if cell.goodsNameField.text != goodsObject.goodsName {
                    self.resultGoods[indexPath.row].imageCache = image
                    return
                }
                cell.fadeIn(image: image, handler: nil)
                self.resultGoods[indexPath.row].imageCache = image
            })
        } else {
            cell.fadeOut(handler: {
                goodsObject.getCoverAsync(handler: { image in
                    if cell.goodsNameField.text != goodsObject.goodsName {
                        self.resultGoods[indexPath.row].imageCache = image
                        return
                    }
                    cell.fadeIn(image: image, handler: nil)
                    self.resultGoods[indexPath.row].imageCache = image
                })
            })
        }

        return cell
    }
    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "GoodsDetailVC") as! GoodsDetailViewController
        destinationViewController.goodsObject = resultGoods[indexPath.row]
//        destinationViewController.modalPresentationStyle = .currentContext
//        destinationViewController.modalTransitionStyle = .coverVertical
        self.present(destinationViewController, animated: true, completion: nil)
    }
}

extension Decimal {
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber)
    }
}
