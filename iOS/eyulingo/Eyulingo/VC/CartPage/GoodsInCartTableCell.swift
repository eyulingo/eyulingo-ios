//
//  GoodsInCartTableCell.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/18.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class GoodsInCartTableCell: UITableViewCell {
    
    var delegate: goToStoreDelegate?
    
    var goodsObject: EyGoods?
    
    @IBOutlet weak var imageViewField: UIImageView!
    @IBOutlet weak var goodsNameField: UILabel!
    @IBOutlet weak var descriptionTextField: UILabel!
    @IBOutlet weak var priceTextField: UILabel!
    @IBOutlet weak var storageTextField: UILabel!
    @IBOutlet weak var storeTextField: UILabel!
    @IBAction func GoToStoreButtonTapped(_ sender: UIButton) {
        self.delegate?.goToStore(goodsObject?.storeId)
    }
    
    func fadeOut(duration: Double = 0.25, handler: (() -> ())?) {
        imageViewField.alpha = 1.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.imageViewField.alpha = 0.0
        }, completion: { _ in
            self.imageViewField.image = nil
            self.imageViewField.alpha = 0.0
            handler?()
        })
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
}
