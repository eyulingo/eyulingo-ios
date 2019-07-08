//
//  AdminBookVC.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class AdminBookHeadlineTableViewCell: UITableViewCell {
    
//    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var storageTextField: UILabel!
    @IBOutlet weak var priceTextField: UILabel!
    @IBOutlet weak var statusLabelField: UILabel!
    
}

class AdminBookVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bookTableView: UITableView!
    
    var bookList: [Book] = []
    var sortedBookDict = [String: [Book]]()
    var indexArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTableView.delegate = self
        bookTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .dark
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAllBooks()
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        Alamofire.request(EyulingoUri.logOutPostUri, method: .post).response(completionHandler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedBookDict[indexArray[section]]?.count ?? 0
    }
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func addNewBookButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addNewBookSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexArray.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexArray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexArray[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func refreshContent() {
        bookTableView.reloadData()
    }
    
    func buildDictionary() {
        indexArray.removeAll()
        sortedBookDict.removeAll()
        
        for book in bookList {
            let result = "\(PYConverter.transformChinese(book.title + book.author).first!)"
            
            if !indexArray.contains(result) {
                indexArray.append(result)
                indexArray.sort()
            }
            
            if sortedBookDict[result] == nil {
                sortedBookDict[result] = [book]
            } else {
                if !sortedBookDict[result]!.contains(where: {
                    return $0.title == book.title
                }) {
                    sortedBookDict[result]!.append(book)
                    sortedBookDict[result]!.sort(by: {$0.title < $1.title} )
                }
            }
            NSLog("\(book.title + book.author) => \(result)")
        }
        refreshContent()
    }
    
    
    func loadAllBooks() {
        bookList.removeAll()
        refreshContent()
        bookTableView.rowHeight = 160
        Alamofire.request(EyulingoUri.adminGetAllBooks,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for bookItem in jsonResp!["data"].arrayValue {
                                self.bookList.append(Book(disabled: bookItem["disabled"].boolValue,
                                                          title: bookItem["title"].stringValue,
                                                          isbn: bookItem["isbn"].stringValue,
                                                          author: bookItem["author"].stringValue,
                                                          description: bookItem["description"].stringValue,
                                                          coverUrl: bookItem["coverUrl"].stringValue,
                                                          storage: bookItem["storage"].intValue,
                                                          price: bookItem["price"].doubleValue,
                                                          couponPrice: bookItem["couponPrice"].doubleValue))
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
                self.makeAlert("加载全部书籍失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
            })
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminBookCell", for: indexPath)
            as! AdminBookHeadlineTableViewCell
        
        let headline = sortedBookDict[indexArray[indexPath.section]]![indexPath.row]
//        cell.coverImage.image = nil
        cell.titleTextField.text = headline.title
        cell.authorTextField.text = "\(headline.author) 著"
        cell.storageTextField.text = "剩余库存 \(headline.storage) 件"
        cell.priceTextField.text = String(format: "¥%.2f", headline.couponPrice)
        if headline.disabled {
            cell.statusLabelField.text = "已隐藏"
        } else {
            cell.statusLabelField.text = ""
        }
//        headline.getImage(handler: { image in
//            cell.coverImage.image = image
//        })
        
        return cell
    }
    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookObject = sortedBookDict[indexArray[indexPath.section]]![indexPath.row]
        
        let alertController = UIAlertController(title: "想进行什么操作？",
                                                message: "您刚刚选定了 \(bookObject.author) 的《\(bookObject.title)》。",
            preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        let changeStorageAction = UIAlertAction(title: "修改库存",
                                                style: .default,
                                                handler: { _ in
                                                    
                                                    let alert = UIAlertController(title: "修改库存", message: "请输入《\(bookObject.title)》的新库存数量。", preferredStyle: .alert)
                                                    
                                                    alert.addTextField { (textField) in
                                                        textField.text = String(bookObject.storage)
                                                        textField.keyboardType = .numberPad
                                                    }
                                                    
                                                    
                                                    alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                                                   
                                                    alert.addAction(UIAlertAction(title: "好", style: .default, handler: { [weak alert] (_) in
                                                        let newStorage = Int(alert?.textFields![0].text! ?? String(bookObject.storage))
                                                        let postParams: Parameters = [
                                                            "isbn": bookObject.isbn,
                                                            "storage": newStorage!
                                                        ]
                                                        Alamofire.request(EyulingoUri.modifyStorage,
                                                                          method: .post,
                                                                          parameters: postParams
                                                            ).responseSwiftyJSON(completionHandler: { responseJSON in
                                                                var errorCode = "general error"
                                                                if responseJSON.error == nil {
                                                                    let jsonResp = responseJSON.value
                                                                    if jsonResp != nil {
                                                                        if jsonResp!["status"].stringValue == "ok" {
                                                                            self.makeAlert("成功", "成功地修改了库存。", completion: {
                                                                                self.loadAllBooks()
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
                                                                self.makeAlert("修改库存失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                                                            })
                                                    }))
                                                    self.present(alert, animated: true, completion: nil)
        })
        
        let peekAction = UIAlertAction(title: "查看详情",
                                      style: .default,
                                      handler: { _ in
            let destinationStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
            destinationViewController.currentBook = bookObject
            self.present(destinationViewController, animated: true, completion: nil)
        })
        
        var activeAction: UIAlertAction?
        
        if bookObject.disabled {
            activeAction = UIAlertAction(title: "显示这本书",
                                         style: .destructive,
                                         handler: { _ in
                                            let postParams: Parameters = [
                                                "isbn": bookObject.isbn
                                            ]
                                            Alamofire.request(EyulingoUri.enableBook,
                                                              method: .post,
                                                              parameters: postParams
                                                ).responseSwiftyJSON(completionHandler: { responseJSON in
                                                    var errorCode = "general error"
                                                    if responseJSON.error == nil {
                                                        let jsonResp = responseJSON.value
                                                        if jsonResp != nil {
                                                            if jsonResp!["status"].stringValue == "ok" {
                                                                self.makeAlert("成功", "成功显示了这本书。\n它现在可以被普通用户查看了。", completion: {
                                                                    self.loadAllBooks()
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
                                                    self.makeAlert("显示书本失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                                                })
            })
        } else {
            activeAction = UIAlertAction(title: "隐藏这本书",
                                         style: .destructive,
                                         handler: { _ in
                                            let postParams: Parameters = [
                                                "isbn": bookObject.isbn
                                            ]
                                            Alamofire.request(EyulingoUri.disableBook,
                                                              method: .post,
                                                              parameters: postParams
                                                ).responseSwiftyJSON(completionHandler: { responseJSON in
                                                    var errorCode = "general error"
                                                    if responseJSON.error == nil {
                                                        let jsonResp = responseJSON.value
                                                        if jsonResp != nil {
                                                            if jsonResp!["status"].stringValue == "ok" {
                                                                self.makeAlert("成功", "成功隐藏了这本书。\n它现在无法被普通用户查看。", completion: {
                                                                    self.loadAllBooks()
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
                                                    self.makeAlert("隐藏书本失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                                                })
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(peekAction)
        alertController.addAction(changeStorageAction)
        alertController.addAction(activeAction!)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
