//
//  AdminAddBookVC.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class AdminAddBookVC: UIViewController {

    @IBOutlet weak var bookName: UITextField!
    @IBOutlet weak var authorName: UITextField!
    @IBOutlet weak var bookIsbn: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var storageTextField: UITextField!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func imageUploadTapped(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
