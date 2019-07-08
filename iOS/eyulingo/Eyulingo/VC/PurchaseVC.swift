//
//  PurchaseVC.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class PurchaseVC: UIViewController, UITextFieldDelegate {
    
    var bookIsbn: String?
    var bookCount: Int?
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isbnTextField.isEnabled = false
        purchaseCount.isEnabled = false
        // Do any additional setup after loading the view.
        isbnTextField.text = bookIsbn ?? ""
        purchaseCount.text = "\(bookCount ?? 0) 套"
        
        deliveryName.delegate = self
        deliveryPhoneNo.delegate = self
        deliveryAddress.delegate = self
        overrideUserInterfaceStyle = .light
    }
    
    @IBOutlet weak var deliveryName: UITextField!
    @IBOutlet weak var deliveryPhoneNo: UITextField!
    @IBOutlet weak var deliveryAddress: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var purchaseCount: UITextField!
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == deliveryName {
            deliveryPhoneNo.becomeFirstResponder()
        } else if textField == deliveryPhoneNo {
            deliveryAddress.becomeFirstResponder()
        } else if textField == deliveryAddress {
            purchaseNow(UIButton())
        }
        return true
    }
    
    
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func purchaseNow(_ sender: UIButton) {
        if bookIsbn == nil || bookCount == nil || deliveryName.text == "" || deliveryPhoneNo.text == "" || deliveryAddress.text == "" {
            makeAlert("错误", "缺失部分必要信息。请再检查检查。", completion: { })
            return
        }
        let postParams: Parameters = [
            "isbn": bookIsbn!,
            "count": bookCount!,
            "later": false,
            "receiver": deliveryName.text!,
            "phoneNo": deliveryPhoneNo.text!,
            "address": deliveryAddress.text!
        ]
        Alamofire.request(BookieUri.purchasePostUri,
                          method: .post,
                          parameters: postParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            self.makeAlert("成功", "订单提交成功。", completion: {
                                self.dismissMe(UIBarButtonItem())
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
                self.makeAlert("失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
            })
    }
}
