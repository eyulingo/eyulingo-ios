//
//  ChangeEmailViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/10.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON
import UIKit

class ChangeEmailViewController: UIViewController, UITextFieldDelegate {
    var originEmailAddress: String?
    
    var delegate: profileRefreshDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        originEmailField.delegate = self
        newEmailField.delegate = self
        confirmCode.delegate = self
        // Do any additional setup after loading the view.

        originEmailField.isEnabled = false
        if originEmailAddress != nil {
            originEmailField.text = originEmailAddress!
        }

        onFieldEdited(originEmailField)
    }

    @IBOutlet var originEmailField: UITextField!
    @IBOutlet var newEmailField: UITextField!
    @IBOutlet var confirmCode: UITextField!

    @IBOutlet var resetButton: UIButton!
    @IBOutlet var submitButton: UIButton!

    @IBOutlet weak var verifyButton: UIButton!
    
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
        newEmailField.text = ""
        confirmCode.text = ""
        onFieldEdited(originEmailField)
    }

    @IBAction func getCheckCode(_ sender: UIButton) {
        let emailAddr = newEmailField.text ?? ""
        if !EmailVerifier.verify(emailAddr) {
            makeAlert("无法发送验证码", "您输入的邮箱格式不正确。请检查后重试。", completion: {})
            return
        }
        let postParams: Parameters = [
            "email": emailAddr,
            "type": 1
        ]

        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        loadingAlert.view.addSubview(loadingIndicator)

        present(loadingAlert, animated: true, completion: {
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
                                   completion: {})
                })
            })
        })
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if newEmailField.text == "" || confirmCode.text == "" {
            makeAlert("换绑邮箱失败", "输入信息不完整。\n请检查后再试一次。", completion: {})
            return
        }

        let postParams: Parameters = [
            "new_email": newEmailField.text!,
            "confirm_code": confirmCode.text!,
        ]

        let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        loadingAlert.view.addSubview(loadingIndicator)

        present(loadingAlert, animated: true, completion: {
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.emailChangePostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                loadingAlert.dismiss(animated: true, completion: {
                                    self.makeAlert("成功", "您的电子邮件地址已更新。", completion: {
                                        self.dismiss(animated: true, completion: {
                                            self.delegate?.refreshProfile()
                                        })
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == originEmailField {
            newEmailField.becomeFirstResponder()
        } else if textField == newEmailField {
            confirmCode.becomeFirstResponder()
        } else if textField == confirmCode {
            confirmCode.resignFirstResponder()
            submitButtonTapped(submitButton)
        }
        return true
    }

    @IBAction func onFieldEdited(_ sender: UITextField) {

        verifyButton.isEnabled = EmailVerifier.verify(newEmailField.text ?? "")

        if newEmailField.text == "" && confirmCode.text == "" {
            resetButton.isEnabled = false
        } else {
            resetButton.isEnabled = true
        }

        if newEmailField.text == "" || confirmCode.text == "" {
            submitButton.isEnabled = false
        } else {
            submitButton.isEnabled = true
        }
    }

    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
