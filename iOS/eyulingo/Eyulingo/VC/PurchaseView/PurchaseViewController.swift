//
//  PurchaseViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/19.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    

    var possibleAddresses: [ReceiveAddress] = []
    
    @IBOutlet weak var recentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

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

        let cancelButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100, y: 0, width: 100, height: 50))
        cancelButton.setTitle("完成", for: UIControl.State.normal)
        cancelButton.setTitle("完成", for: UIControl.State.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControl.State.normal)
        cancelButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: UIControl.Event.touchUpInside) // set button click event
        sender.inputView = inputView
    }

    @objc func doneButtonTapped() {
        hiddenTextField.resignFirstResponder()
    }
    
    @objc func cancelButtonTapped() {
        hiddenTextField.resignFirstResponder()
    }
}
