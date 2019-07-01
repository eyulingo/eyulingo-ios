//
//  AdminBookVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class AdminBookVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    


    @IBOutlet weak var bookTableView: UITableView!
    
    var bookList: [Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTableView.delegate = self
        bookTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminUserCell", for: indexPath)
            as! BookHeadlineTableViewCell
        
        let headline = bookList[indexPath.row]
        
        cell.titleTextField.text = headline.title
        cell.authorTextField.text = "\(headline.author) 著"
        cell.storageTextField.text = "剩余库存 \(headline.storage) 件"
        cell.priceTextField.text = String(format: "¥%.2f", headline.couponPrice)
        headline.getImage(handler: { image in
            cell.coverImage.image = image
        })
        
        return cell
    }
}
