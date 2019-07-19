//
//  GoodsInCartTableCell.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/18.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class GoodsInCartTableCell: UITableViewCell {
    
    
    func initCell() {
        stepper.minimumValue = 0.0
        stepper.maximumValue = Double(storage ?? 100)
        stepper.value = Double(amount)
    }
    
    
    @IBAction func stepperTapped(_ sender: UIStepper) {
        amount = Int(sender.value)
        if goodsId != nil && amount != 0 {
            self.amountModifyDelegate?.updateAmount(goodsId: goodsId, quantity: amount, completion: nil)
            self.amountField.text = "×\(amount)"
        }
    }
    
    var delegate: goToStoreDelegate?
    
    var amountModifyDelegate: AmountModifyDelegate?
    
    var goodsObject: EyGoods?
    
    var amount: Int = 1
    var storage: Int?
    var goodsId: Int?
    
    @IBOutlet weak var imageViewField: UIImageView!
    @IBOutlet weak var goodsNameField: UILabel!
    @IBOutlet weak var priceField: UILabel!
    @IBOutlet weak var amountField: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var storeField: UILabel!
    @IBOutlet weak var storageField: UILabel!
    @IBOutlet weak var inadequatePromptField: UILabel!
    
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

protocol AmountModifyDelegate {
    func updateAmount(goodsId: Int?, quantity: Int, completion: (() -> Void)?) -> ()
}
