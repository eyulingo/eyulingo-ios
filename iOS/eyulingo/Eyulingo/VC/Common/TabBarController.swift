//
//  DarkTabBarController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/2.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class DarkTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
}



class LightTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        overrideUserInterfaceStyle = .light
//        overrideUserInterfaceStyle = .unspecified
        // Do any additional setup after loading the view.
    }
}
