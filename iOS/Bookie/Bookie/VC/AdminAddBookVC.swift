//
//  AdminAddBookVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import YPImagePicker

class AdminAddBookVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var bookName: UITextField!
    @IBOutlet weak var authorName: UITextField!
    @IBOutlet weak var bookIsbn: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var storageTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    
    
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
        
        // Do any additional setup after loading the view.
        bookName.delegate = self
        authorName.delegate = self
        bookIsbn.delegate = self
        descriptionTextField.delegate = self
        storageTextField.delegate = self
        priceTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == bookName {
            authorName.becomeFirstResponder()
        } else if textField == authorName {
            bookIsbn.becomeFirstResponder()
        } else if textField == bookIsbn {
            descriptionTextField.becomeFirstResponder()
        } else if textField == descriptionTextField {
            storageTextField.becomeFirstResponder()
        } else if textField == storageTextField {
            priceTextField.becomeFirstResponder()
        } else {
            priceTextField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func imageUploadTapped(_ sender: UIButton) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.imageView.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    @IBAction func addNewBookHandler(_ sender: UIButton) {
        if bookName.text == "" || authorName.text == "" || bookIsbn.text == ""
            || descriptionTextField.text == "" || storageTextField.text == ""
            || priceTextField.text == ""
            || imageView.image == nil {
            makeAlert("信息不全", "请检查必填字段和图片是否完整。", completion: { })
            return
        }
        
        let bookNameText = bookName.text!
        let authorNameText = authorName.text!
        let bookIsbnText = bookIsbn.text!
        let typeText = self.typeSelector.titleForSegment(at: self.typeSelector.selectedSegmentIndex)!
        let descriptionText = descriptionTextField.text!
        let storageInt = Int(storageTextField.text!) ?? 1
        let priceDouble = Double(priceTextField.text!) ?? 42.0
        
        let loadingAlert = UIAlertController(title: nil, message: "正在上传图片……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        
        guard let data = imageView.image!.jpegData(compressionQuality: 0.9) else {
            loadingAlert.dismiss(animated: true, completion: nil)
            return
        }
        self.present(loadingAlert, animated: true, completion: {
            Alamofire.upload(multipartFormData: { (form) in
                form.append(data, withName: "file",
                            fileName: bookNameText + "_" +  authorNameText + ".jpg",
                            mimeType: "image/jpg")
            }, to: BookieUri.imageCoverUploadUri, encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        let responseJson: JSON = JSON.init(parseJSON: response.value!)
                        if responseJson["status"].stringValue != "ok" {
                            loadingAlert.dismiss(animated: true, completion: {
                                self.makeAlert("上传图片失败", "服务器报告了一个 “\(responseJson["status"])” 错误。",
                                    completion: { })
                            })
                        }
                        let fileId = responseJson["file_id"].stringValue
                        
                        let postParams: Parameters = [
                            "title": bookNameText,
                            "author": authorNameText,
                            "type": typeText,
                            "description": descriptionText,
                            "storage": storageInt,
                            "coverId": fileId,
                            "isbn": bookIsbnText,
                            "price": priceDouble,
                            "coupon_price": priceDouble
                            
                        ]
                        Alamofire.request(BookieUri.addNewBook,
                                          method: .post,
                                          parameters: postParams)
                        .responseSwiftyJSON(completionHandler: { responseJSON in
                            var errorCode = "general error"
                            if responseJSON.error == nil {
                                let jsonResp = responseJSON.value
                                if jsonResp != nil {
                                    if jsonResp!["status"].stringValue == "ok" {
                                        errorCode = "ok"
                                        loadingAlert.dismiss(animated: true, completion: {
                                            self.makeAlert("成功", "成功创建了新的图书。", completion: {
                                                self.dismiss(animated: true, completion: nil)
                                            })
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
                            if errorCode != "ok" {
                                loadingAlert.dismiss(animated: true, completion: {
                                    self.makeAlert("添加画图书失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                                })
                            }
                        })
                    }
                case .failure( _):
                    self.makeAlert("上传图片失败", "服务器报告了一个一般错误。",
                        completion: { })
                }
            })
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

}
