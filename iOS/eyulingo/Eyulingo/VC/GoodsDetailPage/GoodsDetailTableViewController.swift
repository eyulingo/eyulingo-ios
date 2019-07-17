//
//  GoodsDetailTableViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/17.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class GoodsDetailTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        stepper.stepValue = 1.0
        stepper.minimumValue = 1.0
        if goodsObject != nil {
            stepper.maximumValue = max(Double(goodsObject!.storage!), 1.0)
        } else {
            stepper.maximumValue = 1000.0
        }
        stepper.value = 1.0
        
        goodsName.text = goodsObject?.goodsName
        storeName.text = goodsObject?.storeName
        priceField.text = "¥" + (goodsObject?.price?.formattedAmount ?? "未知")
        descriptionField.text = goodsObject?.description
        storageField.text = "\(goodsObject?.storage ?? 0) 件"
        stepperChanged(stepper)
    }
    
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        amountField.text = "\(Int(sender.value)) 件"
    }
    
    @IBOutlet weak var goodsName: UILabel!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var priceField: UILabel!
    @IBOutlet weak var descriptionField: UILabel!
    @IBOutlet weak var storageField: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var amountField: UILabel!
    
    var goodsObject: EyGoods?
    var quantity: Int = 1
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func addToCartButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func purchaseButtonTapped(_ sender: UIButton) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // Tap on table Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            // go to store
        }
    }
}
