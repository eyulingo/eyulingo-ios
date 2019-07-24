//
//  StoreResultTableView.swift
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

class StoreResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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

                            destinationViewController.suicideDelegate = self.parent as! SearchStoreViewController
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
    var resultStores: [EyStore] = []
    
    var keyWord: String?
    
    func reloadData() {
        resultTable.reloadData()
    }
    
    var currentSortMethod: SortMethod = .byDefault
    
    func refreshStyle(style: SortMethod) {
        currentSortMethod = style
        resultTable.reloadData()
    }
    
    // MARK: - delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultStores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let storeObject = resultStores[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultStoresCell", for: indexPath) as! StoreResultTableCell
        
//        tableView.register(GoodsResultTableCell.self, forCellReuseIdentifier: "ResultGoodsCell")
        // 判断系统版本，必须iOS 9及以上，同时检测是否支持触摸力度识别
//        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
//            // 注册预览代理，self监听，tableview执行Peek
//            registerForPreviewing(with: self, sourceView: tableView)
//        }
        
        cell.storeName.text = storeObject.storeName
        cell.storeAddress.text = storeObject.storeAddress
        cell.coverImage.layer.cornerRadius = 4
        
        if currentSortMethod == .byDefault {
            cell.detailLabel.text = ""
        } else if currentSortMethod == .byDistance {
            cell.detailLabel.text = "距离您当前位置 \(String.init(format: "%.2f", storeObject.currentDistance ?? 0.0)) 公里"
        } else if currentSortMethod == .byRate {
            cell.detailLabel.text = " \(storeObject.commentPeopleCount ?? 0) 名用户给出平均分 \(String.init(format: "%.1f", storeObject.commentStar ?? 0.0)) 分"
        } else if currentSortMethod == .byHeat {
            cell.detailLabel.text = "销售 \(storeObject.heatCount ?? 0) 单"
        }

        if keyWord != nil {
            if #available(iOS 13.0, *) {
                cell.highlight(text: keyWord!, normal: nil, highlight: [NSAttributedString.Key.backgroundColor: UIColor.systemFill])
            } else {
                cell.highlight(text: keyWord!, normal: nil, highlight: [NSAttributedString.Key.backgroundColor: UIColor.darkGray])
            }
        }
        
        if storeObject.imageCache != nil {
            cell.coverImage.image = storeObject.imageCache
            return cell
        }
        
        if cell.coverImage.image == nil {
            storeObject.getStoreCoverAsync(handler: { image in
                let prepareString = cell.storeName.text ?? ""
                if prepareString.caseInsensitiveCompare(storeObject.storeName ?? "") != ComparisonResult.orderedSame {
                    if self.resultStores.count > indexPath.row {
                        self.resultStores[indexPath.row].imageCache = image
                    }
                    return
                }
                cell.fadeIn(image: image, handler: nil)
                if self.resultStores.count > indexPath.row {
                    self.resultStores[indexPath.row].imageCache = image
                }
            })
        } else {
            cell.fadeOut(handler: {
                storeObject.getStoreCoverAsync(handler: { image in
                    let prepareString = cell.storeName.text ?? ""
                    if prepareString.caseInsensitiveCompare(storeObject.storeName ?? "") != ComparisonResult.orderedSame {
                        if self.resultStores.count > indexPath.row {
                            self.resultStores[indexPath.row].imageCache = image
                        }
                        return
                    }
                    cell.fadeIn(image: image, handler: nil)
                    if self.resultStores.count > indexPath.row {
                        self.resultStores[indexPath.row].imageCache = image
                    }
                })
            })
        }

        return cell
    }
    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storeObject = resultStores[indexPath.row]
        goToStore(storeObject.storeId)
    }
}
