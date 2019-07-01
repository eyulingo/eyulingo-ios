//
//  PurchasedVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class BillHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var purchaseTimeField: UILabel!
    @IBOutlet weak var deliveryInfoField: UILabel!
    @IBOutlet weak var countField: UILabel!
}

class PurchasedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlines.count
    }
    
    
    var headlines: [Bill] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "billCell", for: indexPath)
            as! BillHeadlineTableViewCell
        
        let headline = headlines[indexPath.row]
        
        cell.titleTextField.text = headline.bookName
        cell.authorTextField.text = "\(headline.author) 著"
        cell.deliveryInfoField.text = "配送给：\(headline.receiver)，\(headline.phoneNo)"
        cell.purchaseTimeField.text = "购买于 \(headline.purchasedTime)"
        cell.countField.text = "×\(headline.count)"
        
        return cell
    }

}
