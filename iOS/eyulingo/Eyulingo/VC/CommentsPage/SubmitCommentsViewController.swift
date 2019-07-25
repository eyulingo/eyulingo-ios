//
//  SubmitCommentsViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/22.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import Loaf
import SwiftyJSON
import UIKit

class SubmitCommentsViewController: UIViewController, ValueChangeDelegate, UITextViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        valueChanged(rateControl.rate)
        rateControl.delegate = self

        if #available(iOS 13.0, *) {
            commentTextField.layer.borderColor = UIColor.tertiaryLabel.cgColor
        } else {
            commentTextField.layer.borderColor = UIColor.lightGray.cgColor
        }
        commentTextField.layer.cornerRadius = 4
        commentTextField.layer.borderWidth = 0.5
        commentTextField.delegate = self
        
        visualEffectView.layer.cornerRadius = 10
    }

    //    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.text != "" {
//            valueChanged(rateControl.rate)
//        } else {
//            commentButton.isEnabled = false
//        }
//    }

    var commentType: CommentType?
    var delegate: CommentsRefreshDelegate?

    @IBAction func dismissMe(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet var rateControl: RateControl!
    @IBOutlet var commentButton: UIButton!

    func valueChanged(_ rate: Int?) {
//        if rate != 0 {
//            commentButton.isEnabled = true
//        } else {
//            commentButton.isEnabled = false
//        }
    }

    @IBAction func commentButtonTapped(_ sender: UIButton) {
        if rateControl.rate == nil || rateControl.rate! == 0 {
            Loaf("通过点击星形符号来评分。", state: .error, sender: self).show()
            return
        }

        if commentTextField.text == "" {
            Loaf("请先填写评论内容。", state: .error, sender: self).show()
            return
        }

        if commentType == CommentType.goodsComments && goodsId != nil {
            let postParams: Parameters = [
                "id": goodsId!,
                "star_count": rateControl.rate ?? 5,
                "comment_content": commentTextField.text!,
            ]
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.commentGoodsPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
//                                Loaf("评论成功。", state: .success, sender: self).show()
                                self.dismiss(animated: true, completion: {
                                    self.delegate?.refreshComments()
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
                    Loaf("评论失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
//                    self.loadRawData()
                })
        } else if commentType == CommentType.storeComments && storeId != nil {
            let postParams: Parameters = [
                "id": storeId!,
                "star_count": rateControl.rate ?? 5,
                "comment_content": commentTextField.text!,
            ]
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.commentStorePostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                //                                Loaf("评论成功。", state: .success, sender: self).show()
                                self.dismiss(animated: true, completion: {
                                    self.delegate?.refreshComments()
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
                    Loaf("评论失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
                    //                    self.loadRawData()
                })
        } else if commentType == CommentType.ordersComments && ordersId != nil {
            let postParams: Parameters = [
                "order_id": ordersId!,
                "star_count": rateControl.rate ?? 5,
                "comment_content": commentTextField.text!,
            ]
            var errorStr = "general error"
            Alamofire.request(Eyulingo_UserUri.rateOrderPostUri,
                              method: .post,
                              parameters: postParams,
                              encoding: JSONEncoding.default)
                .responseSwiftyJSON(completionHandler: { responseJSON in
                    if responseJSON.error == nil {
                        let jsonResp = responseJSON.value
                        if jsonResp != nil {
                            if jsonResp!["status"].stringValue == "ok" {
                                //                                Loaf("评论成功。", state: .success, sender: self).show()
                                self.dismiss(animated: true, completion: {
                                    self.delegate?.refreshComments()
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
                    Loaf("评价失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
                    //                    self.loadRawData()
                })
        }
    }

    var storeId: Int?
    var storeName: String?
    var ordersId: Int?

    @IBOutlet var commentTextField: UITextView!

    var goodsId: Int?
    var goodsName: String?
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

protocol CommentsRefreshDelegate {
    func refreshComments() -> Void
}
