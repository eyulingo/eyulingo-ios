//
//  PurchaseVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class PurchaseVC: UIViewController {
    
    var bookIsbn: String?
    var bookCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isbnTextField.isEnabled = false
        purchaseCount.isEnabled = false
        // Do any additional setup after loading the view.
        isbnTextField.text = bookIsbn ?? ""
        purchaseCount.text = "\(bookCount ?? 0) 套"
    }
    
    @IBOutlet weak var deliveryName: UITextField!
    @IBOutlet weak var deliveryPhoneNo: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var purchaseCount: UITextField!
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
