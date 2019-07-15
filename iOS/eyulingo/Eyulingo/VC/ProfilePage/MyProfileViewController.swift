//
//  MyProfileViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/9.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import YPImagePicker
import Alamofire_SwiftyJSON

class MyProfileViewController: UIViewController, profileChangesDelegate, profileRefreshDelegate, backgroundImageReloadDelegate {
    func fadeOutBg(duration: Double = 1.5) {
        self.backgroundImageView.alpha = 0.8
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.backgroundImageView.alpha = 0.0
        }, completion: { _ in
            self.backgroundImageView.image = nil
            self.backgroundImageView.alpha = 0.0
        })
    }
    
    func fadeInBg(image: UIImage, duration: Double = 1.5) {
        self.backgroundImageView.alpha = 0.0
        self.backgroundImageView.image = image
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.backgroundImageView.alpha = 0.8
        }, completion: { _ in
            self.backgroundImageView.alpha = 0.8
        })
    }
    
    
    func refreshProfile() {
        loadUserProfile()
    }

    var currentUser: EyUser?
    var contentVC: ProfileContentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        
        // Do any additional setup after loading the view.
        loadUserProfile()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if #available(iOS 13.0, *) {
//            overrideUserInterfaceStyle = .dark
//            (self.parent as! UITabBarController).overrideUserInterfaceStyle = .dark
//        }
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        if #available(iOS 13.0, *) {
//            overrideUserInterfaceStyle = .unspecified
//            (self.parent as! UITabBarController).overrideUserInterfaceStyle = .unspecified
//        }
//    }

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if contentVC == nil {
            if segue.identifier == "tableContainerSegue" {
                contentVC = segue.destination as? ProfileContentViewController
                contentVC?.delegate = self
                contentVC?.bgDelegate = self
            }
        }
        
        if segue.identifier == "ChangeEmailSegue" {
            let emailViewController = segue.destination as! ChangeEmailViewController
            emailViewController.originEmailAddress = currentUser?.userEmail
            emailViewController.delegate = self
        }
        
        if segue.identifier == "ChangePasswordSegue" {
            let passwordViewController = segue.destination as! ChangePasswordViewController
            passwordViewController.originUserName = currentUser?.userName
        }
        super.prepare(for: segue, sender: sender)
    }
    
    func updateAvatar() {
        
        let loadingAlert = UIAlertController(title: nil, message: "正在上传图片……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        if currentUser == nil {
            
            makeAlert("更换头像失败", "您尚未登录。请稍后再试。", completion: { })
            return
        }
        
        var config = YPImagePickerConfiguration()
        config.onlySquareImagesFromCamera = false
        config.onlySquareImagesFromLibrary = true
        config.library.onlySquare = true
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.hidesStatusBar = false
        let picker = YPImagePicker(configuration: config)
        
        if #available(iOS 13.0, *) {
            // Picker doesn't support dark mode. Should override it manually
            picker.overrideUserInterfaceStyle = .light
        }
        
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
                loadingAlert.dismiss(animated: true, completion: nil)
                picker.dismiss(animated: true, completion: nil)
            }
            
            if let photo = items.singlePhoto {
                

                guard let data = photo.image.compressImage(size: 200) else {
//                    loadingAlert.dismiss(animated: true, completion: nil)
                    return
                }
                
                picker.present(loadingAlert, animated: true, completion: {
                    Alamofire.upload(multipartFormData: { (form) in
                        form.append(data, withName: "file",
                                    fileName: "\(self.currentUser!.userId!)" + "_" +  self.currentUser!.userName! + ".jpg",
                                    mimeType: "image/jpg")
                    }, to: Eyulingo_UserUri.imagePostUri, encodingCompletion: { result in
                        switch result {
                        case .success(let upload, _, _):
                            upload.responseString { response in
                                if response.error != nil {
                                    loadingAlert.dismiss(animated: true, completion: {
                                        picker.dismiss(animated: true, completion: {
                                            self.makeAlert("上传图片失败", "服务器报告了一个 “no response” 错误。",
                                                completion: { })
                                        })
                                    })
                                    return
                                }
                                let responseJson: JSON = JSON.init(parseJSON: response.value!)
                                if responseJson["status"].stringValue != "ok" {
                                    picker.dismiss(animated: true, completion: {
                                        loadingAlert.dismiss(animated: true, completion: {
                                            self.makeAlert("上传图片失败", "服务器报告了一个 “\(responseJson["status"])” 错误。",
                                                    completion: { })
                                        })
                                    })
                                }
                                let fileId = responseJson["file_id"].stringValue
                                
                                if fileId == "" {
                                    picker.dismiss(animated: true, completion: {
                                        loadingAlert.dismiss(animated: true, completion: {
                                            self.makeAlert("上传图片失败", "图片过大，请再挑一张。",
                                                completion: { })
                                        })
                                    })
                                    return
                                }
                                
                                let postParams: Parameters = [
                                    "avatar_id": fileId
                                ]
                                Alamofire.request(Eyulingo_UserUri.avatarPostUri,
                                                  method: .post,
                                                  parameters: postParams,
                                                  encoding: JSONEncoding.default)
                                    .responseSwiftyJSON(completionHandler: { responseJSON in
                                        var errorCode = "general error"
                                        if responseJSON.error == nil {
                                            let jsonResp = responseJSON.value
                                            if jsonResp != nil {
                                                if jsonResp!["status"].stringValue == "ok" {
                                                    errorCode = "ok"
                                                    loadingAlert.dismiss(animated: true, completion: {
                                                        picker.dismiss(animated: true, completion: {
                                                            self.makeAlert("成功", "成功更新头像。", completion: {
                                                            
                                                            self.loadUserProfile()
                                                            })
                                                        })
                                                    })
                                                    
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
                                            picker.dismiss(animated: true, completion: {
                                                    self.makeAlert("上传图片失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                                            })
                                        }
                                    })
                            }
                        case .failure( _):
                            picker.dismiss(animated: true, completion: {
                                self.makeAlert("上传图片失败", "服务器报告了一个一般错误。",
                                           completion: { })
                            })
                        }
                    })
                })
            }
//            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    func updateEmail() {
        self.performSegue(withIdentifier: "ChangeEmailSegue", sender: self)
    }
    
    func updatePassword() {
        self.performSegue(withIdentifier: "ChangePasswordSegue", sender: self)
    }
    
    func editReceiveAddress() {
//        self.performSegue(withIdentifier: "ManageAddressSegue", sender: self)
        
        let destinationStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "AddressManageVC") as! AddressManageViewController
        self.present(destinationViewController, animated: true, completion: nil)
    }
    
    func contactSupport() {
        
    }
    
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        LogOutHelper.logOutNow {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setProfileInfo() {
        if currentUser != nil {
            self.contentVC?.setUserProfile(avatar: nil,
                                           userId: self.currentUser!.userId!,
                                           userName: self.currentUser!.userName!,
                                           email: self.currentUser!.userEmail!)
            let params: Parameters = [
                "fileId": currentUser!.avatarId!
            ]
            Alamofire.request(Eyulingo_UserUri.imageGetUri,
                              method: .get,
                              parameters: params).responseData(completionHandler: { responseData in
                                if (responseData.data != nil) {
                                    let image = UIImage(data: responseData.data!)
                                    if image != nil {
                                        self.contentVC?.setUserProfile(avatar: image!,
                                                              userId: self.currentUser!.userId!,
                                                              userName: self.currentUser!.userName!,
                                          email: self.currentUser!.userEmail!)
                                    } else {
                                        self.makeAlert("获取个人资料失败", "无法加载您的头像。", completion: {
                                            self.contentVC?.setUserProfile(avatar: nil,
                                                                           userId: self.currentUser!.userId!,
                                                                      userName: self.currentUser!.userName!,
                                                                      email: self.currentUser!.userEmail!)
                                        })
                                    }
                                } else {
                                    self.makeAlert("获取个人资料失败", "无法加载您的头像。", completion: {
                                        self.contentVC?.setUserProfile(avatar: nil,
                                                                       userId: self.currentUser!.userId!,
                                                                       userName: self.currentUser!.userName!,
                                                                       email: self.currentUser!.userEmail!)
                                    })
                                }
                                
            })
        } else {
            self.contentVC?.setUserProfile(avatar: nil,
                                           userId: -1,
                                           userName: "未知",
                                           email: "未知")
        }
    }
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func loadUserProfile() {
        Alamofire.request(Eyulingo_UserUri.profileGetUri,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            self.currentUser = EyUser(avatarId: jsonResp!["avatar"].string,
                                                 userName: jsonResp!["username"].string,
                                                 userId: jsonResp!["userid"].int,
                                                 userEmail: jsonResp!["email"].string)
                            self.setProfileInfo()
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
                self.makeAlert("获取个人资料失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
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

protocol profileRefreshDelegate {
    func refreshProfile() -> ()
}


protocol backgroundImageReloadDelegate {
    func fadeOutBg(duration: Double) -> ()
    func fadeInBg(image: UIImage, duration: Double) -> ()
}
