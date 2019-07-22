//
//  CommentsViewController.swift
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

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsBody.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath)
        let commentsObject = commentsBody[indexPath.row]
        cell.textLabel?.text = "“\(commentsObject.userName ?? "未知用户")”给出 \(commentsObject.commentStars ?? 5) 颗星"
        cell.detailTextLabel?.text = commentsObject.commentContents ?? "评论内容"
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        disableStars()
        // Do any additional setup after loading the view.
        loadComments()
    }

    var contentType: CommentType?
    var storeId: Int?
    var goodsId: Int?
    
    var starPeopleNumber: Int?

    var storeObject: EyStore?
    var goodsObject: EyGoods?

    var commentsBody: [EyComments] = []

    func loadComments() {
        commentsBody.removeAll()
        if contentType == CommentType.storeComments && storeId != nil {
            loadStoreComments()
        } else if contentType == CommentType.goodsComments && goodsId != nil {
            loadGoodsComments()
        }
    }
    
    func checkHiddenOrNot() {
        if commentsBody.count == 0 {
            noContentIndicator.isHidden = false
        } else {
            noContentIndicator.isHidden = true
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "来自消费者的评价"
    }

    func loadStoreComments() {
        var errorStr = "general error"
        let getParams: Parameters = [
            "id": storeId!,
        ]
        Alamofire.request(Eyulingo_UserUri.storeDetailGetUri,
                          method: .get,
                          parameters: getParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            self.starPeopleNumber = jsonResp!["star_number"].intValue
                            for commentItem in jsonResp!["comments"].arrayValue {
                                self.commentsBody.append(EyComments(userName: commentItem["username"].stringValue,
                                                                    commentStars: commentItem["star_count"].intValue,
                                                                    commentContents: commentItem["comment_content"].stringValue))
                            }
                            self.checkHiddenOrNot()
                            self.commentsTableView.reloadData()
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
                Loaf("加载评论失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
            })
        NSLog("request ended with " + errorStr)
    }

    func loadGoodsComments() {
        var errorStr = "general error"
        let getParams: Parameters = [
            "id": goodsId!,
        ]
        Alamofire.request(Eyulingo_UserUri.goodDetailGetUri,
                          method: .get,
                          parameters: getParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            self.starPeopleNumber = jsonResp!["star_number"].intValue
                            for commentItem in jsonResp!["comments"].arrayValue {
                                self.commentsBody.append(EyComments(userName: commentItem["username"].stringValue,
                                                                    commentStars: commentItem["star_count"].intValue,
                                                                    commentContents: commentItem["comment_content"].stringValue))
                            }
                            self.checkHiddenOrNot()
                            self.commentsTableView.reloadData()
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
                Loaf("加载评论失败。服务器报告了一个 “\(errorStr)” 错误", state: .error, sender: self).show()
            })
        NSLog("request ended with " + errorStr)
    }

    @IBAction func writeComments(_ sender: UIButton) {
        // 再说吧
    }

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var commentPeopleCountLabel: UILabel!

    @IBOutlet var scoreLabel: UILabel!

    @IBOutlet var noContentIndicator: UILabel!

    @IBOutlet var starOne: UIImageView!
    @IBOutlet var starTwo: UIImageView!
    @IBOutlet var starThree: UIImageView!
    @IBOutlet var starFour: UIImageView!
    @IBOutlet var starFive: UIImageView!

    @IBOutlet var commentsTableView: UITableView!

    func updateStarValue(value: Double) {
        if value >= 5.0 {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star.fill")
            starThree.image = UIImage(named: "star.fill")
            starFour.image = UIImage(named: "star.fill")
            starFive.image = UIImage(named: "star.fill")
        } else if value >= 4.5 {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star.fill")
            starThree.image = UIImage(named: "star.fill")
            starFour.image = UIImage(named: "star.fill")
            starFive.image = UIImage(named: "star.lefthalf.fill")
        } else if value >= 4.0 {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star.fill")
            starThree.image = UIImage(named: "star.fill")
            starFour.image = UIImage(named: "star.fill")
            starFive.image = UIImage(named: "star")
        } else if value >= 3.5 {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star.fill")
            starThree.image = UIImage(named: "star.fill")
            starFour.image = UIImage(named: "star.lefthalf.fill")
            starFive.image = UIImage(named: "star")
        } else if value >= 3.0 {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star.fill")
            starThree.image = UIImage(named: "star.fill")
            starFour.image = UIImage(named: "star")
            starFive.image = UIImage(named: "star")
        } else if value >= 2.5 {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star.fill")
            starThree.image = UIImage(named: "star.lefthalf.fill")
            starFour.image = UIImage(named: "star")
            starFive.image = UIImage(named: "star")
        } else if value >= 2.0 {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star.fill")
            starThree.image = UIImage(named: "star")
            starFour.image = UIImage(named: "star")
            starFive.image = UIImage(named: "star")
        } else if value >= 1.5 {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star.lefthalf.fill")
            starThree.image = UIImage(named: "star")
            starFour.image = UIImage(named: "star")
            starFive.image = UIImage(named: "star")
        } else {
            starOne.image = UIImage(named: "star.fill")
            starTwo.image = UIImage(named: "star")
            starThree.image = UIImage(named: "star")
            starFour.image = UIImage(named: "star")
            starFive.image = UIImage(named: "star")
        }
    }

    func disableStars() {
        scoreLabel.text = "无评分"
        commentPeopleCountLabel.text = "由于评分人数不足，无法显示评分。"
        starOne.image = UIImage(named: "star.slash")
        starTwo.image = UIImage(named: "star.slash")
        starThree.image = UIImage(named: "star.slash")
        starFour.image = UIImage(named: "star.slash")
        starFive.image = UIImage(named: "star.slash")
    }
    
    func updateStars() {
        if starPeopleNumber == nil || starPeopleNumber == 0 || commentsBody.count == 0 {
            disableStars()
            return
        }
        commentPeopleCountLabel.text = "\(starPeopleNumber ?? 0) 名用户评分的平均值"
        var totalStarCount: Double = 0.0
        for commentItem in commentsBody {
            totalStarCount += Double(commentItem.commentStars ?? 0)
        }
        let averageStar = totalStarCount / Double(starPeopleNumber ?? 1)
        if averageStar < 0.0 || averageStar > 5.0 {
            disableStars()
            return
        }
        scoreLabel.text = String.init(format: "%.2d 分", averageStar)
        updateStarValue(value: averageStar)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

enum CommentType {
    case storeComments
    case goodsComments
}
