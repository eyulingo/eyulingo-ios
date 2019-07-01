//
//  AdminOrderVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class AdminBillHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var purchaseTimeField: UILabel!
    @IBOutlet weak var deliveryInfoField: UILabel!
    @IBOutlet weak var countField: UILabel!
}

class AdminOrderVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlines.count
    }
    

    var headlines: [AdminBill] = []
    
    var isbns: [String] = []
    var userIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminBillCell", for: indexPath)
            as! AdminBillHeadlineTableViewCell
        
        let headline = headlines[indexPath.row]
        
        cell.titleTextField.text = "ISBN: \(headline.bookIsbn)"
        cell.deliveryInfoField.text = ""
        cell.authorTextField.text = ""
        cell.purchaseTimeField.text = "购买于 \(headline.timeStamp)"
        cell.countField.text = "×\(headline.count)"
        
        return cell
    }
}
