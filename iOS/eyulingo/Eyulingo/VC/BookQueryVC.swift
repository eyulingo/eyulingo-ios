//
//  BookQueryVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class BookHeadlineTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var storageTextField: UILabel!
    @IBOutlet weak var priceTextField: UILabel!
}


class BookQueryVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        Alamofire.request(BookieUri.logOutPostUri, method: .post).response(completionHandler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
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
    

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableViewContent: UITableView!
    
    
    var bookList: [Book] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchTextOver(textField)
            searchTextField.resignFirstResponder()
        }
        return true
    }
    
    func refreshContent() {
        tableViewContent.reloadData()
    }

    func searchTextOver(_ sender: UITextField) {
        if sender.text == "" {
            return
        }
        bookList.removeAll()
        tableViewContent.reloadData()
        tableViewContent.rowHeight = 160
        NSLog("Gotta search request: \(String(describing: sender.text))")
        if sender.text == nil {
            return
        }
        let keyWord = sender.text!
        let getParams: Parameters = [
            "q": keyWord
        ]
        Alamofire.request(BookieUri.bookSearchGetUri,
                          method: .get, parameters: getParams)
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
            self.makeAlert("检索失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "queryBookCell", for: indexPath)
            as! BookHeadlineTableViewCell
        
        let headline = bookList[indexPath.row]
        cell.coverImage.image = nil
        cell.titleTextField.text = headline.title
        cell.authorTextField.text = "\(headline.author) 著"
        cell.storageTextField.text = "剩余库存 \(headline.storage) 件"
        cell.priceTextField.text = String(format: "¥%.2f", headline.couponPrice)
        headline.getImage(handler: { image in
            if cell.titleTextField.text == headline.title {
                cell.coverImage.image = image
                cell.coverImage.contentMode = .scaleAspectFill
            }
        })
        return cell
    }
    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookObject = bookList[indexPath.row]
        
        let destinationStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
        destinationViewController.currentBook = bookObject
        self.present(destinationViewController, animated: true, completion: {
            self.searchTextOver(self.searchTextField)
        })
    }
}
