//
//  BookDetailVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class BookDetailVC: UIViewController {

    @IBOutlet weak var navigateTitle: UINavigationItem!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var countPicker: UISegmentedControl!
    @IBOutlet weak var descriptionTextField: UILabel!
    @IBOutlet weak var isbnText: UILabel!
    @IBOutlet weak var storageTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var currentBook: Book?
    
    @IBAction func addToCart(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func purchaseNow(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
