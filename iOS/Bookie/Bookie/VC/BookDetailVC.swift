//
//  BookDetailVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class BookDetailVC: UIViewController {

    @IBOutlet weak var navigateTitle: UINavigationItem!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var countPicker: UISegmentedControl!
    @IBOutlet weak var descriptionTextField: UILabel!
    @IBOutlet weak var isbnText: UILabel!
    @IBOutlet weak var storageTextField: UILabel!
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: nil)
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: completion)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentBook?.getImage(handler: { image in
            self.coverView.image = image
            self.coverView.contentMode = .scaleAspectFit
        })
        navigateTitle.title = currentBook?.title
        authorTextField.text = (currentBook?.author ?? "未知作者") + " 著"
        descriptionTextField.text = currentBook?.description
        isbnText.text = currentBook?.isbn
        storageTextField.text = "\(currentBook?.storage ?? 0)" + " 册"
    }
    
    var currentBook: Book?
    
    @IBAction func addToCart(_ sender: UIButton) {
        if currentBook == nil {
            return
        }
        let postParams: Parameters = [
            "isbn": currentBook!.isbn,
            "count": countPicker.selectedSegmentIndex + 1,
            "later": true
        ]
        
        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        self.present(loadingAlert, animated: true, completion: {
            Alamofire.request(BookieUri.addToCartPostUri,
                              method: .post,
                              parameters: postParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            loadingAlert.dismiss(animated: true, completion: nil)
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
                loadingAlert.dismiss(animated: true, completion: {
                    self.makeAlert("加入购物车失败", "服务器报告了一个 “\(errCode)” 错误。",
                        completion: { })
                })
            })
        })
    }
    
    @IBAction func purchaseNow(_ sender: UIButton) {
        if currentBook == nil {
            return
        }
        let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "PurchaseVC") as! PurchaseVC
        destinationViewController.bookIsbn = currentBook!.isbn
        destinationViewController.bookCount = countPicker.selectedSegmentIndex + 1
        self.present(destinationViewController, animated: true, completion: nil)
    }
    
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
