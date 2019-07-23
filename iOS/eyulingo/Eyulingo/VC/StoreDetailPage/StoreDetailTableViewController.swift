//
//  StoreDetailTableViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/18.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON

class StoreDetailTableViewController: UITableViewController {

    @IBOutlet weak var storeCoverImageField: UIImageView!
    @IBOutlet weak var storeNameField: UILabel!
    @IBOutlet weak var storePhoneField: UILabel!
    @IBOutlet weak var storeLocationField: UILabel!
    
    @IBOutlet weak var distAvatarImageField: UIImageView!
    @IBOutlet weak var distNameField: UILabel!
    
    var storeObject: EyStore?
    var openedByGoodsId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(GoodsResultTableCell.self, forCellReuseIdentifier: "GoodsInStoreCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        storeObject?.getStoreCoverAsync(handler: { image in
            self.coverFadeIn(image: image, handler: nil)
        })
        storeNameField.text = storeObject?.storeName
        storePhoneField.text = storeObject?.storePhone
        storeLocationField.text = storeObject?.storeAddress
        
        storeCoverImageField.layer.cornerRadius = 4
        distAvatarImageField.layer.cornerRadius = 4
        
        storeObject?.getDistAvatarAsync(handler: { image in
            self.avatarFadeIn(image: image, handler: nil)
        })
        distNameField.text = storeObject?.distName
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 4
        } else if section == 1 {
            return 2
        }
        return storeObject?.storeGoods?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section != 2 {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let goodsObject = storeObject?.storeGoods?[indexPath.row]

        let cell = Bundle.main.loadNibNamed("GoodsInStoreCell", owner: nil, options: nil)?.last as! GoodsResultTableCell
        
        
        cell.goodsNameField.text = goodsObject?.goodsName ?? "商品名"
        cell.descriptionTextField.text = goodsObject?.description ?? "商品描述"
        cell.priceTextField.text = "¥" + (goodsObject?.price?.formattedAmount ?? "未知")
        cell.storageTextField.text = "库存 \(goodsObject?.storage ?? 0) 件"
        cell.storeTextField.text = goodsObject?.storeName ?? "店铺未知"
        cell.imageViewField.layer.cornerRadius = 4
        // Configure the cell...

        if goodsObject?.imageCache != nil {
            cell.imageViewField.image = goodsObject?.imageCache
            return cell
        }
        
        if cell.imageViewField.image == nil {
            goodsObject?.getCoverAsync(handler: { image in
                if cell.goodsNameField.text != goodsObject?.goodsName {
                    self.storeObject?.storeGoods?[indexPath.row].imageCache = image
                    return
                }
                cell.fadeIn(image: image, handler: nil)
                self.storeObject?.storeGoods?[indexPath.row].imageCache = image
            })
        } else {
            cell.fadeOut(handler: {
                goodsObject?.getCoverAsync(handler: { image in
                    if cell.goodsNameField.text != goodsObject?.goodsName {
                        self.storeObject?.storeGoods?[indexPath.row].imageCache = image
                        return
                    }
                    cell.fadeIn(image: image, handler: nil)
                    self.storeObject?.storeGoods?[indexPath.row].imageCache = image
                })
            })
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 144.0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 2 {
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 0))
        }
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }

    // Tap on table Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if storeCoverImageField.image == nil {
                    return
                }
                let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "ImagePreviewVC") as! ImagePreviewViewController
                
                destinationViewController.mainImage = storeCoverImageField.image
                destinationViewController.promptText = "“\(self.storeObject?.storeName ?? "商店")” 图像"
                self.present(destinationViewController, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.becomeFirstResponder()
                    let copyItem = UIMenuItem(title: "拷贝", action: #selector(copyStoreName))
                    let menuController = UIMenuController.shared
                    menuController.menuItems = [copyItem]
                    menuController.setTargetRect(cell.frame, in: cell.superview!)
                    menuController.setMenuVisible(true, animated: true)
                }
            } else if indexPath.row == 2 {
                guard let number = URL(string: "tel://" + self.storePhoneField.text!) else { return }
                UIApplication.shared.open(number)
            } else if indexPath.row == 3 {
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.becomeFirstResponder()
                    let copyItem = UIMenuItem(title: "拷贝", action: #selector(copyAddress))

                    let menuController = UIMenuController.shared
                    menuController.menuItems = [copyItem]
                    menuController.setTargetRect(cell.frame, in: cell.superview!)
                    menuController.setMenuVisible(true, animated: true)
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if distAvatarImageField.image == nil {
                    return
                }
                let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "ImagePreviewVC") as! ImagePreviewViewController
                
                destinationViewController.mainImage = distAvatarImageField.image
                destinationViewController.promptText = "“\(self.storeObject?.distName ?? "经销商")” 的头像"
                self.present(destinationViewController, animated: true, completion: nil)
            }
        } else if indexPath.section == 2 {
            openGoodsDetail((storeObject?.storeGoods?[indexPath.row].goodsId)!,
                            imgCache: (tableView.cellForRow(at: indexPath) as! GoodsResultTableCell).imageViewField.image)
        }
    }
    
    @objc func copyStoreName() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = storeObject?.storeName
    }
    
    @objc func copyAddress() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = storeObject?.storeAddress
    }
    
    func openGoodsDetail(_ goodsId: Int, imgCache: UIImage? = nil) {
        if goodsId == openedByGoodsId {
            self.dismiss(animated: true, completion: nil)
            return
        }
        var errorStr = "general error"
        let getParams: Parameters = [
            "id": goodsId
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
                            destinationViewController.suicideDelegate = self.parent as! StoreDetailViewController
                            destinationViewController.goodsObject = goodObj
                            destinationViewController.openedByStoreId = self.storeObject?.storeId
                            
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func coverFadeIn(image: UIImage, duration: Double = 0.25, handler: (() -> ())?) {
        storeCoverImageField.alpha = 0.0
        storeCoverImageField.image = image
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.storeCoverImageField.alpha = 1.0
        }, completion: { _ in
            self.storeCoverImageField.alpha = 1.0
            handler?()
        })
    }
    
    func avatarFadeIn(image: UIImage, duration: Double = 0.25, handler: (() -> ())?) {
        distAvatarImageField.alpha = 0.0
        distAvatarImageField.image = image
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.distAvatarImageField.alpha = 1.0
        }, completion: { _ in
            self.distAvatarImageField.alpha = 1.0
            handler?()
        })
    }

}
