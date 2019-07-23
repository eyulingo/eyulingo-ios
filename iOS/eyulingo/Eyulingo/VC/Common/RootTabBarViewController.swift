//
//  RootTabBarViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/23.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class RootTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        blurredTabBar.backgroundImage = UIImage(ciImage: CIImage.init(color: CIColor.clear))
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var blurredTabBar: BlurredTabBar!
    
    func searchWord(keyWord: String) {
        tabBarController?.selectedIndex = 0
        (children[0] as! SearchViewController)
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
