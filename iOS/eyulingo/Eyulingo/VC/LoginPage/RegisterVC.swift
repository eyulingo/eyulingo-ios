//
//  RegisterVC.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class RegisterVC: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
//        overrideUserInterfaceStyle = .light

        userNameField.delegate = self
        eMailField.delegate = self
        captchaTextField.delegate = self
        passWordField.delegate = self
        confirmPassWordField.delegate = self
        // Do any additional setup after loading the view.
        onFieldEdited(userNameField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var eMailField: UITextField!
    @IBOutlet weak var captchaTextField: UITextField!
    @IBOutlet weak var passWordField: UITextField!
    @IBOutlet weak var confirmPassWordField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField {
            eMailField.becomeFirstResponder()
        } else if textField == eMailField {
            captchaTextField.becomeFirstResponder()
        } else if textField == captchaTextField {
            passWordField.becomeFirstResponder()
        } else if textField == passWordField {
            confirmPassWordField.becomeFirstResponder()
        } else {
            confirmPassWordField.resignFirstResponder()
            registerButtonTapped(registerButton)
        }
        return true
    }
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func onFieldEdited(_ sender: UITextField) {
        if EmailVerifier.verify(eMailField.text ?? "") {
            verifyButton.isEnabled = true
        } else {
            verifyButton.isEnabled = false
        }
        if userNameField.text == "" && eMailField.text == "" && passWordField.text == "" && confirmPassWordField.text == "" && captchaTextField.text == "" {
            resetButton.isEnabled = false
        } else {
            resetButton.isEnabled = true
        }
        
        if userNameField.text == "" || eMailField.text == "" || passWordField.text == "" || confirmPassWordField.text == "" || passWordField.text != confirmPassWordField.text || captchaTextField.text == "" {
            registerButton.isEnabled = false
        } else {
            registerButton.isEnabled = true
        }
    }
    
    @IBAction func getCheckCode(_ sender: UIButton) {
        let emailAddr = eMailField.text ?? ""
        if !EmailVerifier.verify(emailAddr) {
            makeAlert("无法发送验证码", "您输入的邮箱格式不正确。请检查后重试。", completion: { })
            return
        }
        let postParams: Parameters = [
            "email": emailAddr,
            "type": 0
        ]
        
        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        self.present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
        Alamofire.request(Eyulingo_UserUri.captchaGetPostUri,
                          method: .post,
                          parameters: postParams,
                          encoding: JSONEncoding.default).responseSwiftyJSON(completionHandler: { responseJSON in
                            if responseJSON.error == nil {
                                let jsonResp = responseJSON.value
                                if jsonResp != nil {
                                    if jsonResp!["status"].stringValue == "ok" {
                                        loadingAlert.dismiss(animated: true, completion: {
                                            self.makeAlert("发送成功", "请检查“\(emailAddr)”的收件箱。", completion: {
                                                
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
                                    completion: { })
                            })
                          })
        })
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        userNameField.text = ""
        eMailField.text = ""
        captchaTextField.text = ""
        passWordField.text = ""
        confirmPassWordField.text = ""
        onFieldEdited(userNameField)
    }

    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        let postParams: Parameters = [
            "email": eMailField.text!,
            "username": userNameField.text!,
            "password": passWordField.text!,
            "confirm_password": confirmPassWordField.text!,
            "confirm_code": captchaTextField.text!
        ]
        
        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        self.present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.registerPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                loadingAlert.dismiss(animated: true, completion: {
                                    self.makeAlert("注册成功", "您现在可以登录 Eyulingo 了。", completion: {
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
                    loadingAlert.dismiss(animated: true, completion: {
                        self.makeAlert("注册失败", "服务器报告了一个 “\(errorStr)” 错误。",
                            completion: { })
                    })
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
