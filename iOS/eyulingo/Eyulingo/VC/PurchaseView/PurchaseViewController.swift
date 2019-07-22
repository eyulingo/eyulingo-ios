//
//  PurchaseViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/19.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: removeGoodsFromCartDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return toPurchaseGoods.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderPageGoodsCell", for: indexPath)
            let cartObject = toPurchaseGoods[indexPath.row]
            cell.textLabel?.text = cartObject.goodsName ?? "商品"
            cell.detailTextLabel?.text = "¥" + (cartObject.price?.formattedAmount ?? "?.??") + "×\(cartObject.amount ?? 0)"
            return cell
        }
        
        var sumUp: Decimal = Decimal(integerLiteral: 0)
        for item in toPurchaseGoods {
            sumUp += (item.price ?? Decimal(integerLiteral: 0)) * Decimal(integerLiteral: item.amount ?? 0)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderPageGoodsCell", for: indexPath)
        cell.textLabel?.text = "总金额"
        cell.detailTextLabel?.text = "¥" + (sumUp.formattedAmount ?? "?.??")
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    //    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    //        return existedStores
    //    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "商品详情"
        }
        return "小计"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == receiverTextField {
            contactPhoneTextField.becomeFirstResponder()
        } else if textField == contactPhoneTextField {
            addressTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        if receiverTextField.text != "" && contactPhoneTextField.text != "" && addressTextField.text != "" && toPurchaseGoods.count != 0 {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }

    var toPurchaseGoods: [EyCarts] = []

    var possibleAddresses: [ReceiveAddress] = []
    
    @IBOutlet weak var goodsTableView: UITableView!
    @IBOutlet weak var recentButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBAction func confirmPurchaseButtonTapped(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        textChanged(receiverTextField)
        // Do any additional setup after loading the view.
        
        hiddenTextField.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if possibleAddresses.count == 0 {
            recentButton.isEnabled = false
        }
        
        receiverTextField.delegate = self
        contactPhoneTextField.delegate = self
        addressTextField.delegate = self
    }
    @IBOutlet weak var receiverTextField: UITextField!
    @IBOutlet weak var contactPhoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    var pickerView: UIPickerView! = UIPickerView()
    @IBOutlet weak var hiddenTextField: UITextField!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Delegates and data sources

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return possibleAddresses.count
    }

    //MARK: Delegates

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let address: ReceiveAddress = possibleAddresses[row]
        return "\(address.address ?? "收件地址")"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        print("Hello", "didSelectRow: ", row)
        receiverTextField.text = possibleAddresses[row].receiver
        contactPhoneTextField.text = possibleAddresses[row].phoneNo
        addressTextField.text = possibleAddresses[row].address
        textChanged(receiverTextField)
    }

    @IBAction func showPickerView(sender: UIButton) {
        if possibleAddresses.count > 0 {
            pickerView(pickerView, didSelectRow: pickerView.selectedRow(inComponent: 0), inComponent: 0)
            hiddenTextField.becomeFirstResponder()
        }
    }

    func cancelPicker(sender: UIButton) {
        //Remove view when select cancel
        hiddenTextField.resignFirstResponder()
    }

    @IBAction func textField(sender: UITextField) {
//        //Create the view
        let tintColor: UIColor = UIColor.systemBlue
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        
        pickerView.tintColor = tintColor
        pickerView.center.x = inputView.center.x
        inputView.addSubview(pickerView) // add date picker to UIView
//        let doneButton = UIButton(frame: CGRect(x: 100/2, y: 0, width: 100, height: 50))
//        doneButton.setTitle("选定", for: UIControl.State.normal)
//        doneButton.setTitle("选定", for: UIControl.State.highlighted)
//        doneButton.setTitleColor(tintColor, for: UIControl.State.normal)
//        doneButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
//        inputView.addSubview(doneButton) // add Button to UIView
//        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: UIControl.Event.touchUpInside) // set button click event

//        let cancelButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100, y: 0, width: 100, height: 50))
//        cancelButton.setTitle("完成", for: UIControl.State.normal)
//        cancelButton.setTitle("完成", for: UIControl.State.highlighted)
//        cancelButton.setTitleColor(tintColor, for: UIControl.State.normal)
//        cancelButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
//        inputView.addSubview(cancelButton) // add Button to UIView
//        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: UIControl.Event.touchUpInside) // set button click event
        sender.inputView = inputView
    }

    @objc func doneButtonTapped() {
        hiddenTextField.resignFirstResponder()
    }
    
    @objc func cancelButtonTapped() {
        hiddenTextField.resignFirstResponder()
    }
}

protocol removeGoodsFromCartDelegate {
    func removePurchasedGoods(goods: [EyCarts]) -> ()
}
