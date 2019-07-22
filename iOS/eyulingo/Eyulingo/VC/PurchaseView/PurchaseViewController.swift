//
//  PurchaseViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/19.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import Loaf
import SwiftyJSON
import UIKit

class PurchaseViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var delegate: removeGoodsFromCartDelegate?
    var refreshDelegate: CartRefreshDelegate?

    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        refreshDelegate?.refreshCart()
    }

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
            cell.textLabel?.text = "\(cartObject.amount ?? 0) 件 “\(cartObject.goodsName ?? "商品")”"
            cell.detailTextLabel?.text = "¥" + (cartObject.price?.formattedAmount ?? "?.??")
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
        dismiss(animated: true, completion: nil)
    }

    @IBAction func textChanged(_ sender: UITextField) {
        if receiverTextField.text != "" && contactPhoneTextField.text != "" && addressTextField.text != "" && toPurchaseGoods.count != 0 {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }

    var toPurchaseGoods: [EyCarts] = []

    var orderIds: [Int]?

    var possibleAddresses: [ReceiveAddress] = []

    @IBOutlet var goodsTableView: UITableView!
    @IBOutlet var recentButton: UIButton!
    @IBOutlet var confirmButton: UIButton!

    @IBAction func confirmPurchaseButtonTapped(_ sender: UIButton) {
        if receiverTextField.text != "" && contactPhoneTextField.text != "" && addressTextField.text != "" && toPurchaseGoods.count != 0 {
            // test passed
        } else {
            return
        }

        var contentValues: [Parameters] = []

        for goodsItem in toPurchaseGoods {
            contentValues.append([
                "id": goodsItem.goodsId!,
                "amount": goodsItem.amount!,
            ])
        }
        let postParams: Parameters = [
            "receive_name": receiverTextField.text!,
            "receive_phone": contactPhoneTextField.text!,
            "receive_address": addressTextField.text!,
            "values": contentValues,
        ]

        Alamofire.request(Eyulingo_UserUri.purchasePostUri,
                          method: .post,
                          parameters: postParams,
                          encoding: JSONEncoding.default
        ).responseSwiftyJSON(completionHandler: { responseJSON in
            var errorCode = "general error"
            if responseJSON.error == nil {
                let jsonResp = responseJSON.value
                if jsonResp != nil {
                    if jsonResp!["status"].stringValue == "ok" {
                        self.orderIds = []
                        for orderId in jsonResp!["order_id"].arrayValue {
                            self.orderIds?.append(orderId.intValue)
                        }
//                        self.constructData()
                        self.requestPurchase()
                        self.delegate?.removePurchasedGoods(goods: self.toPurchaseGoods)
//                        Loaf("成功将 “\(cartName!)” 从购物车中移除。", state: .success, sender: self).show()
                        return
                    } else {
                        errorCode = jsonResp!["status"].stringValue
                    }
                } else {
                    errorCode = "bad response"
                }
            } else {
                errorCode = "no response"
            }
            Loaf("未能成功提交这笔订单。服务器报告了一个 “\(errorCode)” 错误", state: .error, sender: self).show()
        })
    }

    func requestPurchase() {
        if orderIds == nil || orderIds!.count == 0 {
            return
        }
        var promptText = "生成了如下 \(orderIds!.count) 笔订单："
        for id in orderIds! {
            promptText += "\n#\(id)"
        }
        promptText += "\n想要立即支付，还是稍后支付？"
        let alert = UIAlertController(title: "订单创建完成", message: promptText, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "稍后", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "立即支付", style: .default, handler: { [weak alert] _ in
            var paramIds: [Parameters] = []
            for id in self.orderIds! {
                paramIds.append([
                    "order_id": id
                ])
            }
            let postParams: Parameters = [
                "order_id": paramIds
            ]

            let loadingAlert = UIAlertController(title: nil, message: "请稍等……", preferredStyle: .alert)

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
            loadingIndicator.startAnimating()

            loadingAlert.view.addSubview(loadingIndicator)

            self.present(loadingAlert, animated: true, completion: {
                var errorStr = "general error"
                Alamofire.request(Eyulingo_UserUri.payPostUri,
                                  method: .post,
                                  parameters: postParams,
                                  encoding: JSONEncoding.default)
                    .responseSwiftyJSON(completionHandler: { responseJSON in
                        if responseJSON.error == nil {
                            let jsonResp = responseJSON.value
                            if jsonResp != nil {
                                if jsonResp!["status"].stringValue == "ok" {
                                    loadingAlert.dismiss(animated: true, completion: {
                                        self.makeAlert("成功", "您已成功支付订单。", completion: {
                                            self.dismiss(animated: true, completion: nil)
                                        })
                                    })
                                    return
                                } else {
                                    errorStr = jsonResp!["status"].stringValue
                                }
                            } else {
                                errorStr = "bad response"
                            }
                        } else {
                            errorStr = "no response"
                        }
                        Loaf("支付失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
                    })
            })
        }))
        present(alert, animated: true, completion: nil)
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

    @IBOutlet var receiverTextField: UITextField!
    @IBOutlet var contactPhoneTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!

    var pickerView: UIPickerView! = UIPickerView()
    @IBOutlet var hiddenTextField: UITextField!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Delegates and data sources

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return possibleAddresses.count
    }

    // MARK: Delegates

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
        // Remove view when select cancel
        hiddenTextField.resignFirstResponder()
    }

    @IBAction func textField(sender: UITextField) {
//        //Create the view
        let tintColor: UIColor = UIColor.systemBlue
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 240))

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
    func removePurchasedGoods(goods: [EyCarts]) -> Void
}
