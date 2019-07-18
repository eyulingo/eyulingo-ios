//
//  StoreDetailViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/18.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class StoreDetailViewController: UIViewController {

    
    var storeObject: EyStore?
    var contentVC: StoreDetailTableViewController?
    
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        storeObject?.getStoreCoverAsync(handler: { image in
//            self.fadeIn(image: image, duration: 1.0, handler: nil)
//        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if contentVC == nil {
            if segue.identifier == "StoreDetailSegue" {
                contentVC = segue.destination as? StoreDetailTableViewController
                contentVC?.storeObject = storeObject
            }
        }
    }
    
    func fadeIn(image: UIImage, duration: Double = 0.25, handler: (() -> ())?) {
        imageViewField.alpha = 0.0
        imageViewField.image = image
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.imageViewField.alpha = 1.0
        }, completion: { _ in
            self.imageViewField.alpha = 1.0
            handler?()
        })
    }
    
    @IBOutlet weak var imageViewField: UIImageView!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
