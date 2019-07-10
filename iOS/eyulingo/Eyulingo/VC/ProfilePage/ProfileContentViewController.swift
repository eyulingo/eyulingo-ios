//
//  ProfileContentViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/9.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class ProfileContentViewController: UITableViewController {
    
    var delegate: profileChangesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var avatarImageField: UIImageView!
    @IBOutlet weak var idTextField: UILabel!
    @IBOutlet weak var nickNameTextField: UILabel!
    @IBOutlet weak var emailTextField: UILabel!
    
    func setUserProfile(avatar: UIImage?,
                        userId: Int,
                        userName: String,
                        email: String) {
        
        avatarImageField.image = avatar
        idTextField.text = "#\(userId)"
        nickNameTextField.text = userName
        emailTextField.text = email
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                let alertController = UIAlertController(title: "想进行什么操作？",
                                                        message: "您可以修改自己的头像。",
                                                        preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "取消",
                                                 style: .cancel,
                                                 handler: nil)
                
                let changeAvatarAction = UIAlertAction(title: "修改头像",
                                                       style: .default,
                                                       handler: { _ in
                                                        self.delegate?.updateAvatar()
                                                        
                })
                alertController.addAction(cancelAction)
                alertController.addAction(changeAvatarAction)
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
                }
                
                self.present(alertController, animated: true, completion: nil)
            } else if indexPath.row == 3 {
                
                let alertController = UIAlertController(title: "想进行什么操作？",
                                                        message: "您可以修改绑定的电子邮箱。",
                                                        preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "取消",
                                                 style: .cancel,
                                                 handler: nil)
                
                let changeAvatarAction = UIAlertAction(title: "修改电子邮箱",
                                                       style: .default,
                                                       handler: { _ in
                                                        self.delegate?.updateEmail()
                                                        
                })
                alertController.addAction(cancelAction)
                alertController.addAction(changeAvatarAction)
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
                }
                
                self.present(alertController, animated: true, completion: nil)
                
            } else if indexPath.row == 4 {
                self.delegate?.updatePassword()
            }
        } else {
            if indexPath.row == 0 {
                self.delegate?.editReceiveAddress()
            } else if indexPath.row == 1 {
                self.delegate?.contactSupport()
            }
        }
    }
}


protocol profileChangesDelegate {
    func updateAvatar() -> ()
//    func updateUserName() -> ()
    func updateEmail() -> ()
    func updatePassword() -> ()
    func editReceiveAddress() -> ()
    func contactSupport() -> ()
}
