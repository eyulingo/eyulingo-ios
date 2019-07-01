//
//  AdminBookVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class AdminBookHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var storageTextField: UILabel!
    @IBOutlet weak var priceTextField: UILabel!
}

class AdminBookVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bookTableView: UITableView!
    
    var bookList: [Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTableView.delegate = self
        bookTableView.dataSource = self
        loadAllBooks()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookList.count
    }
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func refreshContent() {
        bookTableView.reloadData()
    }
    
    func loadAllBooks() {
        bookList.removeAll()
        refreshContent()
        Alamofire.request(BookieUri.adminGetAllBooks,
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
                self.makeAlert("加载全部书籍失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
            })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminBookCell", for: indexPath)
            as! AdminBookHeadlineTableViewCell
        
        let headline = bookList[indexPath.row]
        
        cell.titleTextField.text = headline.title
        cell.authorTextField.text = "\(headline.author) 著"
        cell.storageTextField.text = "剩余库存 \(headline.storage) 件"
        cell.priceTextField.text = String(format: "¥%.2f", headline.couponPrice)
        headline.getImage(handler: { image in
            cell.coverImage.image = image
        })
        
        return cell
    }
}
