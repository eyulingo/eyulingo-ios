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

class MyProfileViewController: UIViewController, profileChangesDelegate {
    
    
    var currentUser: EyUser?
    var contentVC: ProfileContentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        // Do any additional setup after loading the view.
        loadUserProfile()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if contentVC == nil {
            if segue.identifier == "tableContainerSegue" {
                contentVC = segue.destination as? ProfileContentViewController
                contentVC?.delegate = self
            }
        }
        super.prepare(for: segue, sender: sender)
    }
    
    func updateAvatar() {
        
        let loadingAlert = UIAlertController(title: nil, message: "正在上传图片……", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        
        if currentUser == nil {
            
            makeAlert("更换头像失败", "您尚未登录。请稍后再试。", completion: { })
            return
        }
        
        var config = YPImagePickerConfiguration()
        config.onlySquareImagesFromCamera = true
        config.onlySquareImagesFromLibrary = true
        config.library.onlySquare = true
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                
                guard let data = photo.image.jpegData(compressionQuality: 0.8) else {
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
                                                            self.contentVC?.avatarImageField.image = photo.image
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
                                                loadingAlert.dismiss(animated: true, completion: {
                                                    self.makeAlert("上传图片失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: { })
                                                })
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
    
    func updateUserName() {
        
    }
    
    func updateEmail() {
        
    }
    
    func updatePassword() {
        
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        LogOutHelper.logOutNow {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setProfileInfo() {
        if currentUser != nil {
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