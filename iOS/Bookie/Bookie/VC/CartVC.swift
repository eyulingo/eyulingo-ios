//
//  CartVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON


class CartHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var countTextField: UILabel!
    @IBOutlet weak var priceTextField: UILabel!
    
}

class CartVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        Alamofire.request(BookieUri.logOutPostUri, method: .post).response(completionHandler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlines.count
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
    
    var headlines: [Cart] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        loadMyCart()
//        tableViewContent.rowHeight = 130
        overrideUserInterfaceStyle = .light
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
                loadMyCart()
                tableViewContent.rowHeight = 130
    }
    
    func refreshContent() {
        tableViewContent.reloadData()
    }

    
    func loadMyCart() {
        headlines.removeAll()
        refreshContent()
        Alamofire.request(BookieUri.myCartGetUri,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for cartItem in jsonResp!["data"].arrayValue {
                                self.headlines.append(Cart(title: cartItem["title"].stringValue,
                                                           count: cartItem["count"].intValue,
                                                           isbn: cartItem["isbn"].stringValue,
                                                           author: cartItem["author"].stringValue,
                                                           couponPrice: cartItem["price"].doubleValue))
                                self.refreshContent()
                            }
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
                self.makeAlert("获取选物车失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
            })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath)
            as! CartHeadlineTableViewCell
        
        let headline = headlines[indexPath.row]
        
        cell.titleTextField.text = headline.title
        cell.authorTextField.text = headline.author
        cell.priceTextField.text = "¥\(String(format: "%.2f", headline.couponPrice))"
        cell.countTextField.text = "×\(headline.count)"
        return cell
    }
    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cartObject = headlines[indexPath.row]
        
        let alertController = UIAlertController(title: "想进行什么操作？",
                                                message: "您刚刚选定了\(cartObject.author)的《\(cartObject.title)》。",
                                                preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        
        let deleteAction = UIAlertAction(title: "从购物车删除",
                                         style: .destructive,
                                         handler: { _ in
                                            let postParams: Parameters = [
                                                "isbn": cartObject.isbn
                                            ]
                                            Alamofire.request(BookieUri.removeFromCartPostUri,
                                                              method: .post,
                                                              parameters: postParams)
                                                .responseSwiftyJSON(completionHandler: { responseJSON in
                                                    var errorCode = "general error"
                                                    if responseJSON.error == nil {
                                                        let jsonResp = responseJSON.value
                                                        if jsonResp != nil {
                                                            if jsonResp!["status"].stringValue == "ok" {
                                                                self.makeAlert("成功", "成功从购物车中移除。", completion: {
                                                                    self.loadMyCart()
                                                                })
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
                                                    self.makeAlert("获取选物车失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                                                })
        })
        let archiveAction = UIAlertAction(title: "立即购买",
                                          style: .default,
                                          handler: { _ in
                                            let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "PurchaseVC") as! PurchaseVC
                                            destinationViewController.bookIsbn = cartObject.isbn
                                            destinationViewController.bookCount = cartObject.count
                                            self.present(destinationViewController, animated: true, completion: {
                                                self.loadMyCart()
                                            })
            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(archiveAction)
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
