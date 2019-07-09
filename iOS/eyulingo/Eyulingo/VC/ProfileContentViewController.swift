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
        if indexPath.row == 0 {
            self.delegate?.updateAvatar()
        } else if indexPath.row == 4 {
            self.delegate?.updateEmail()
        } else if indexPath.row == 5 {
            self.delegate?.updatePassword()
        }
    }
}


protocol profileChangesDelegate {
    func updateAvatar() -> ()
    func updateUserName() -> ()
    func updateEmail() -> ()
    func updatePassword() -> ()
}
