//
//  StoreResultTableCell.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/23.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class StoreResultTableCell: UITableViewCell {
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var storeName: UILabel!
    @IBOutlet var storeAddress: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func fadeOut(duration: Double = 0.25, handler: (() -> Void)?) {
        coverImage.alpha = 1.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.coverImage.alpha = 0.0
        }, completion: { _ in
            self.coverImage.image = nil
            self.coverImage.alpha = 0.0
            handler?()
        })
    }

    func fadeIn(image: UIImage, duration: Double = 0.25, handler: (() -> Void)?) {
        coverImage.alpha = 0.0
        coverImage.image = image
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.coverImage.alpha = 1.0
        }, completion: { _ in
            self.coverImage.alpha = 1.0
            handler?()
        })
    }
}
