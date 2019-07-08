//
//  LoginVC.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class LoginVC: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        // Do any additional setup after loading the view.
        textChanged(userNameField)
        
        userNameField.delegate = self
        passwordField.delegate = self
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
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
            loginButtonTapped(loginButton)
        }
        return true
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        if userNameField.text == "" && passwordField.text == "" {
            resetButton.isEnabled = false
        } else {
            resetButton.isEnabled = true
        }
        
        if userNameField.text == "" || passwordField.text == "" {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToRegisterSegue", sender: self)
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        userNameField.text = ""
        passwordField.text = ""
        textChanged(userNameField)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let postParams: Parameters = [
            "username": userNameField.text!,
            "password": passwordField.text!
        ]
        
        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        self.present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
            Alamofire.request(EyulingoUri.loginPostUri,
                              method: .post,
                              parameters: postParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "login_successfully" {
                            let role = jsonResp!["role"].stringValue
                            if role == "R_ADMIN" {
                                loadingAlert.dismiss(animated: true, completion: {
//                                    let destinationStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                                    let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "NormalUserVC") as! UITabBarController
//                                    self.present(destinationViewController, animated: true, completion: nil)
                                    self.performSegue(withIdentifier: "adminUserSegue", sender: self)
                                })
                            } else {
                                loadingAlert.dismiss(animated: true, completion: {
//                                    let destinationStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                                    let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "AdminVC") as! UITabBarController
//                                    self.present(destinationViewController, animated: true, completion: nil)
                                    self.performSegue(withIdentifier: "normalUserSegue", sender: self)
                                })
                            }
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
                        self.makeAlert("登录失败", "您的账户已被冻结。再注册一个吧（×）",
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
}
