//
//  ChangePasswordViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/10.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        originPasswordField.delegate = self
        newPasswordField.delegate = self
        confirmNewPasswordField.delegate = self
        
        onFieldEdited(originPasswordField)
        
        // Do any additional setup after loading the view.
        
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(dismissMe(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var originPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmNewPasswordField: UITextField!
    
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
         self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == originPasswordField {
            newPasswordField.becomeFirstResponder()
        } else if textField == newPasswordField {
            confirmNewPasswordField.becomeFirstResponder()
        } else if textField == confirmNewPasswordField {
            confirmNewPasswordField.resignFirstResponder()
            submitButtonTapped(submitButton)
        }
        return true
    }
    
    @IBAction func onFieldEdited(_ sender: UITextField) {
        if originPasswordField.text == "" && newPasswordField.text == "" && confirmNewPasswordField.text == "" {
            restoreButton.isEnabled = false
        } else {
            restoreButton.isEnabled = true
        }
        
        if originPasswordField.text == "" || newPasswordField.text == "" || confirmNewPasswordField.text == "" || newPasswordField.text != confirmNewPasswordField.text {
            submitButton.isEnabled = false
        } else {
            submitButton.isEnabled = true
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if originPasswordField.text == "" || newPasswordField.text == "" || confirmNewPasswordField.text == "" || newPasswordField.text != confirmNewPasswordField.text {
            makeAlert("修改密码失败", "输入不合法。\n请检查后再试一次。", completion: { })
            return
        }
        
        let postParams: Parameters = [
            "origin_password": originPasswordField.text!,
            "new_password": newPasswordField.text!,
            "confirm_new_password": confirmNewPasswordField.text!
        ]
        
        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        self.present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
        Alamofire.request(Eyulingo_UserUri.passwordChangePostUri,
                          method: .post,
                          parameters: postParams,
                          encoding: JSONEncoding.default)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            loadingAlert.dismiss(animated: true, completion: {
                                self.makeAlert("成功", "您的密码已更新。\n下次请使用新密码登入 Eyulingo。", completion: {
                                        self.dismiss(animated: true, completion: nil)
                                    })
                            })
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
                
                if errorStr == "account_locked" {
                    loadingAlert.dismiss(animated: true, completion: {
                        self.makeAlert("修改密码失败", "您的账户已被冻结。",
                                       completion: { })
                    })
                } else {
                    loadingAlert.dismiss(animated: true, completion: {
                        self.makeAlert("登录失败", "服务器报告了一个 “\(errorStr)” 错误。",
                            completion: { })
                    })
                }
            })
        })
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        originPasswordField.text = ""
        newPasswordField.text = ""
        confirmNewPasswordField.text = ""
        onFieldEdited(originPasswordField)
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
