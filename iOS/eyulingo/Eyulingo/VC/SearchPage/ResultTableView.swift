//
//  ResultTableView.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/17.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Highlighter



class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet var resultTable: UITableView!
    var resultGoods: [EyGoods] = []
    
    var keyWord: String?
    
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
        
//        tableView.register(GoodsResultTableCell.self, forCellReuseIdentifier: "ResultGoodsCell")
        // 判断系统版本，必须iOS 9及以上，同时检测是否支持触摸力度识别
//        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
//            // 注册预览代理，self监听，tableview执行Peek
//            registerForPreviewing(with: self, sourceView: tableView)
//        }
        
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
        
        if keyWord != nil {
            if #available(iOS 13.0, *) {
                cell.highlight(text: keyWord!, normal: nil, highlight: [NSAttributedString.Key.backgroundColor: UIColor.systemFill])
            } else {
                cell.highlight(text: keyWord!, normal: nil, highlight: [NSAttributedString.Key.backgroundColor: UIColor.darkGray])
            }
        }
        return cell
    }
    
    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destinationStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = destinationStoryboard.instantiateViewController(withIdentifier: "GoodsDetailVC") as! GoodsDetailViewController
        destinationViewController.goodsObject = resultGoods[indexPath.row]
//        destinationViewController.modalPresentationStyle = .currentContext
//        destinationViewController.modalTransitionStyle = .coverVertical
        self.present(destinationViewController, animated: true, completion: nil)
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
