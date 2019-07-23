//
//  BlurredTabBar.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/23.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class BlurredTabBar: UITabBar {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        frost.frame = bounds
        frost.autoresizingMask = .flexibleWidth
        insertSubview(frost, at: 0)
    }
}
