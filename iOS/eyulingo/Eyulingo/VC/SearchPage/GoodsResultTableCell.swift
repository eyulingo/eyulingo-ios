//
//  GoodsResultTableCell.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/16.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class GoodsResultTableCell: UITableViewCell {
    
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
}

protocol goToStoreDelegate {
    func goToStore(_ storeId: Int?) -> ()
}
