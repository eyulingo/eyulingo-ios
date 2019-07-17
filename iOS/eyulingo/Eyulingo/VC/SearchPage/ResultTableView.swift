//
//  ResultTableView.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/17.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet var resultTable: UITableView!
    var resultGoods: [EyGoods] = []
    
    func reloadData() {
        resultTable.reloadData()
    }
    
    // MARK: - delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let goodsObject = resultGoods[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultGoodsCell", for: indexPath) as! GoodsResultTableCell
        cell.goodsNameField.text = goodsObject.goodsName ?? "商品名"
        cell.descriptionTextField.text = goodsObject.description ?? "商品描述"
        cell.priceTextField.text = "¥" + (goodsObject.price?.formattedAmount ?? "未知")
        cell.storageTextField.text = "库存 \(goodsObject.storage ?? 0) 件"
        cell.storeTextField.text = goodsObject.storeName ?? "店铺未知"
        
        if goodsObject.imageCache != nil {
            cell.imageViewField.image = goodsObject.imageCache
            return cell
        }
        
        if cell.imageViewField.image == nil {
            goodsObject.getCoverAsync(handler: { image in
                if cell.goodsNameField.text != goodsObject.goodsName {
                    return
                }
                cell.fadeIn(image: image, handler: nil)
                self.resultGoods[indexPath.row].imageCache = image
            })
        } else {
            cell.fadeOut(handler: {
                goodsObject.getCoverAsync(handler: { image in
                    if cell.goodsNameField.text != goodsObject.goodsName {
                        return
                    }
                    cell.fadeIn(image: image, handler: nil)
                    self.resultGoods[indexPath.row].imageCache = image
                })
            })
        }
        return cell
    }
    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Decimal {
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber)
    }
}
