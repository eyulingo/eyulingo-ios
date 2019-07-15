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

    var bgDelegate: backgroundImageReloadDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet var avatarImageField: UIImageView!
    @IBOutlet var idTextField: UILabel!
    @IBOutlet var nickNameTextField: UILabel!
    @IBOutlet var emailTextField: UILabel!

    func setUserProfile(avatar: UIImage?,
                        userId: Int,
                        userName: String,
                        email: String) {
        if avatar != nil {
            showImage(image: avatar!)
        } else {
            if avatarImageField.image != nil {
                hideImage()
            }
        }
        idTextField.text = "#\(userId)"
        nickNameTextField.text = userName
        emailTextField.text = email
    }

    func hideImage(duration: Double = 0.25) {
        avatarImageField.alpha = 1.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.avatarImageField.alpha = 0.0
        }, completion: { _ in
            self.avatarImageField.image = nil
            self.avatarImageField.alpha = 0.0
        })

        bgDelegate?.fadeOutBg(duration: 1.0)
    }

    func showImage(image: UIImage, duration: Double = 0.25) {
        avatarImageField.alpha = 0.0
        avatarImageField.image = image
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.avatarImageField.alpha = 1.0
        }, completion: { _ in
            self.avatarImageField.alpha = 1.0
        })

        bgDelegate?.fadeInBg(image: image, duration: 1.0)
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

                let seeBigImageAction = UIAlertAction(title: "查看大图",
                                                      style: .default,
                                                      handler: { _ in
                                                          let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                          let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "ImagePreviewVC") as! ImagePreviewViewController

                                                          destinationViewController.mainImage = self.avatarImageField.image
                                                        destinationViewController.promptText = "“\(self.nickNameTextField.text ?? "我")”的头像"
                                                          self.present(destinationViewController, animated: true, completion: nil)

                })
                alertController.addAction(cancelAction)
                
                if self.avatarImageField.image != nil {
                    alertController.addAction(seeBigImageAction)
                    alertController.message = "您可以查看或修改自己的头像。"
                }
 
                alertController.addAction(changeAvatarAction)
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = view
                    popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
                }

                present(alertController, animated: true, completion: nil)
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
                    popoverController.sourceView = view
                    popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
                }

                present(alertController, animated: true, completion: nil)

            } else if indexPath.row == 4 {
                delegate?.updatePassword()
            }
        } else {
            if indexPath.row == 0 {
                delegate?.editReceiveAddress()
            } else if indexPath.row == 1 {
                delegate?.contactSupport()
            }
        }
    }
}

protocol profileChangesDelegate {
    func updateAvatar() -> Void
//    func updateUserName() -> ()
    func updateEmail() -> Void
    func updatePassword() -> Void
    func editReceiveAddress() -> Void
    func contactSupport() -> Void
}
