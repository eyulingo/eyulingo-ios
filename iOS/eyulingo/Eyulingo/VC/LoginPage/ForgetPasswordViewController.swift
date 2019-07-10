//
//  ForgetPasswordViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/10.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class ForgetPasswordViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        userNameField.delegate = self
        captchaField.delegate = self
        newPasswordField.delegate = self
        confirmNewPasswordField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField {
            captchaField.becomeFirstResponder()
        } else if textField == captchaField {
            newPasswordField.becomeFirstResponder()
        } else if textField == newPasswordField {
            confirmNewPasswordField.becomeFirstResponder()
        } else {
            confirmNewPasswordField.resignFirstResponder()
            submitButtonTapped(submitButton)
        }
        return true
    }
    
    @IBAction func onFieldEdited(_ sender: UITextField) {
        
        getCheckCodeButton.isEnabled = userNameField.text != ""
        
        if userNameField.text == "" && captchaField.text == "" && newPasswordField.text == "" && confirmNewPasswordField.text == "" {
            resetButton.isEnabled = false
        } else {
            resetButton.isEnabled = true
        }
        
        if userNameField.text == "" || captchaField.text == "" || newPasswordField.text == "" || confirmNewPasswordField.text == "" {
            submitButton.isEnabled = false
        } else {
            submitButton.isEnabled = true
        }
    }
    
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var captchaField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmNewPasswordField: UITextField!
    
    @IBOutlet weak var getCheckCodeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        // originEmailField.text = ""
        userNameField.text = ""
        captchaField.text = ""
        newPasswordField.text = ""
        confirmNewPasswordField.text = ""
        onFieldEdited(userNameField)
    }
    
    
    @IBAction func getCheckCode(_ sender: UIButton) {
        let userName = userNameField.text ?? ""
        if userName == "" {
            makeAlert("无法发送验证码", "您的输入数据不全。请检查后重试。", completion: {})
            return
        }
        let postParams: Parameters = [
            "username": userName,
        ]
        
        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.findCheckCodePostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default).responseSwiftyJSON(completionHandler: { responseJSON in
                                if responseJSON.error == nil {
                                    let jsonResp = responseJSON.value
                                    if jsonResp != nil {
                                        if jsonResp!["status"].stringValue == "ok" {
                                            loadingAlert.dismiss(animated: true, completion: {
                                                self.makeAlert("成功", "请检查您的账户所绑定的邮箱。", completion: {
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
                                loadingAlert.dismiss(animated: true, completion: {
                                    self.makeAlert("获取验证码失败", "服务器报告了一个 “\(errorStr)” 错误。",
                                        completion: {})
                                })
                              })
        })
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if userNameField.text == "" || captchaField.text == "" || newPasswordField.text == "" || confirmNewPasswordField.text == ""{
            makeAlert("找回密码失败", "输入信息不完整。\n请检查后再试一次。", completion: {})
            return
        }
        
        let postParams: Parameters = [
            "username": userNameField.text!,
            "new_password": newPasswordField.text!,
            "confirm_password": confirmNewPasswordField.text!,
            "check_code": captchaField.text!
        ]
        
        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.resetPasswordPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                loadingAlert.dismiss(animated: true, completion: {
                                    self.makeAlert("成功", "您的密码已重置。请使用新密码登录 Eyulingo。", completion: {
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
                            self.makeAlert("更改失败", "您的账户已被冻结。",
                                           completion: {})
                        })
                    } else {
                        loadingAlert.dismiss(animated: true, completion: {
                            self.makeAlert("更改失败", "服务器报告了一个 “\(errorStr)” 错误。",
                                completion: {})
                        })
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
