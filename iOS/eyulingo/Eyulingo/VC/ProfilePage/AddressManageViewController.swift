//
//  AddressManageViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/11.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON
import UIKit

class AddressManageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }

    var receiveAddresses: [ReceiveAddress] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receiveAddresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressLabelCell", for: indexPath)

        cell.textLabel?.text = (receiveAddresses[indexPath.row].receiver ?? "收件人")
            + "，"
            + (receiveAddresses[indexPath.row].phoneNo ?? "联系电话")

        cell.detailTextLabel?.text = receiveAddresses[indexPath.row].address ?? "收件地址"

        return cell
    }

    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet var noContentLabel: UILabel!

    @IBOutlet var addressTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadReceiveAddress()
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let originUserName = receiveAddresses[indexPath.row].receiver ?? ""
        let originPhone = receiveAddresses[indexPath.row].phoneNo ?? ""
        let originAddress = receiveAddresses[indexPath.row].address ?? ""
        // 编辑
        let editAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "编辑") { _, _ in

            let alert = UIAlertController(title: "编辑收货地址", message: "请输入新的收货地址。", preferredStyle: .alert)

            alert.addTextField { textField in
                textField.text = originUserName
                textField.placeholder = "收件人姓名"
            }

            alert.addTextField { textField in
                textField.text = originPhone
                textField.placeholder = "联系电话"
                textField.keyboardType = .phonePad
            }

            alert.addTextField { textField in
                textField.text = originAddress
                textField.placeholder = "收件地址"
            }

            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

            alert.addAction(UIAlertAction(title: "好", style: .default, handler: { [weak alert] _ in

                let receiver = alert?.textFields![0].text ?? ""
                let receivePhone = alert?.textFields![1].text ?? ""
                let receiveAddress = alert?.textFields![2].text ?? ""

                if receiver == "" || receivePhone == "" || receiveAddress == "" {
                    alert?.dismiss(animated: true, completion: {
                        self.makeAlert("失败", "输入信息不完整。", completion: {})
                    })
                    return
                }

                let postParams: Parameters = [
                    "old_receive_name": originUserName,
                    "old_receive_phone": originPhone,
                    "old_receive_address": originAddress,
                    "new_receive_name": receiver,
                    "new_receive_phone": receivePhone,
                    "new_receive_address": receiveAddress,
                ]
                Alamofire.request(Eyulingo_UserUri.changeAddressPostUri,
                                  method: .post,
                                  parameters: postParams,
                                  encoding: JSONEncoding.default
                ).responseSwiftyJSON(completionHandler: { responseJSON in
                    var errorCode = "general error"
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                self.loadReceiveAddress()
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
                    self.makeAlert("修改收货地址失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: {})
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        editAction.backgroundColor = .systemBlue

        // 删除
        let deleteAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "移除") { _, _ in

            let alert = UIAlertController(title: "确认操作", message: "确定要删除这条收货地址吗？", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { [weak alert] _ in

                let postParams: Parameters = [
                    "receive_name": originUserName,
                    "receive_phone": originPhone,
                    "receive_address": originAddress,
                ]
                Alamofire.request(Eyulingo_UserUri.removeAddressPostUri,
                                  method: .post,
                                  parameters: postParams,
                                  encoding: JSONEncoding.default
                ).responseSwiftyJSON(completionHandler: { responseJSON in
                    var errorCode = "general error"
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                self.loadReceiveAddress()
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
                    alert?.dismiss(animated: true, completion: {
                        self.makeAlert("删除失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: {})
                    })
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }

        return [deleteAction, editAction]
    }

    // DataSource
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 移动行的时候做一些处理
    }

    // Delegate
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        // 编辑状态下的Cell是否需要缩进
        return true
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        // 开始编辑
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        // 结束编辑
    }

    func refreshContent() {
        addressTableView.reloadData()

        if receiveAddresses.count == 0 {
            noContentLabel.isHidden = false
        } else {
            noContentLabel.isHidden = true
        }
    }

    func loadReceiveAddress() {
        receiveAddresses.removeAll()
        refreshContent()
        Alamofire.request(Eyulingo_UserUri.addressGetUri,
                          method: .get)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for addressItem in jsonResp!["values"].arrayValue {
                                self.receiveAddresses.append(ReceiveAddress(receiver: addressItem["receive_name"].stringValue,
                                                                            phoneNo: addressItem["receive_phone"].stringValue,
                                                                            address: addressItem["receive_address"].stringValue))
                                self.refreshContent()
                            }
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
                self.makeAlert("获取常用地址失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: {})
            })
    }

    @IBAction func addNewAddress(_ sender: UIButton) {
        let alert = UIAlertController(title: "增加常用收货地址", message: "请输入新的收货地址。", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = ""
            textField.placeholder = "收件人姓名"
        }
        

        alert.addTextField { textField in
            textField.text = ""
            textField.placeholder = "联系电话"
            textField.keyboardType = .phonePad
        }

        alert.addTextField { textField in
            textField.text = ""
            textField.placeholder = "收件地址"
        }

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { [weak alert] _ in

            let receiver = alert?.textFields![0].text ?? ""
            let receivePhone = alert?.textFields![1].text ?? ""
            let receiveAddress = alert?.textFields![2].text ?? ""

            if receiver == "" || receivePhone == "" || receiveAddress == "" {
                alert?.dismiss(animated: true, completion: {
                    self.makeAlert("失败", "输入信息不完整。", completion: {})
                })
                return
            }

            let postParams: Parameters = [
                "receive_name": receiver,
                "receive_phone": receivePhone,
                "receive_address": receiveAddress,
            ]
            Alamofire.request(Eyulingo_UserUri.addAddressPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default
            ).responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            self.loadReceiveAddress()
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
                self.makeAlert("添加收货地址失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: {})
            })
        }))
        present(alert, animated: true, completion: nil)
    }

    // Tap on table Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let originUserName = receiveAddresses[indexPath.row].receiver ?? ""
        let originPhone = receiveAddresses[indexPath.row].phoneNo ?? ""
        let originAddress = receiveAddresses[indexPath.row].address ?? ""
        
        tableView.deselectRow(at: indexPath, animated: true)

        let alert = UIAlertController(title: "编辑收货地址", message: "请输入新的收货地址。", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = originUserName
            textField.placeholder = "收件人姓名"
        }

        alert.addTextField { textField in
            textField.text = originPhone
            textField.placeholder = "联系电话"
            textField.keyboardType = .phonePad
        }

        alert.addTextField { textField in
            textField.text = originAddress
            textField.placeholder = "收件地址"
        }

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { [weak alert] _ in

            let receiver = alert?.textFields![0].text ?? ""
            let receivePhone = alert?.textFields![1].text ?? ""
            let receiveAddress = alert?.textFields![2].text ?? ""

            if receiver == "" || receivePhone == "" || receiveAddress == "" {
                alert?.dismiss(animated: true, completion: {
                    self.makeAlert("失败", "输入信息不完整。", completion: {})
                })
                return
            }

            let postParams: Parameters = [
                "old_receive_name": originUserName,
                "old_receive_phone": originPhone,
                "old_receive_address": originAddress,
                "new_receive_name": receiver,
                "new_receive_phone": receivePhone,
                "new_receive_address": receiveAddress,
            ]
            Alamofire.request(Eyulingo_UserUri.changeAddressPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default
            ).responseSwiftyJSON(completionHandler: { responseJSON in
                var errorCode = "general error"
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            self.loadReceiveAddress()
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
                self.makeAlert("修改收货地址失败", "服务器报告了一个 “\(errorCode)” 错误。", completion: {})
            })
        }))
        present(alert, animated: true, completion: nil)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
