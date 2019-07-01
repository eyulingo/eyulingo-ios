//
//  CartVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit


class CartHeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var storageTextField: UILabel!
    @IBOutlet weak var countTextField: UILabel!
    @IBOutlet weak var priceTextField: UILabel!
    
}

class CartVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlines.count
    }
    

    var headlines: [Cart] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath)
            as! CartHeadlineTableViewCell
        
        let headline = headlines[indexPath.row]
        
        cell.titleTextField.text = headline.title
        cell.authorTextField.text = headline.author
        cell.storageTextField.text = "剩余库存 \(headline.storage) 件"
        cell.priceTextField.text = "¥\(String(format: "%.2f", headline.couponPrice))"
        cell.countTextField.text = "×\(headline.count)"
        return cell
    }
}
