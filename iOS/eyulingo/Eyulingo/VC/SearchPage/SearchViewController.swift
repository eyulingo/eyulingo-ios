//
//  SearchViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/9.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class SearchViewController: UIViewController, ModernSearchBarDelegate, SearchDelegate {
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }

    
    func performSearch(_ query: String?) {
        NSLog("Should perform search to \(query ?? "(null)")")
        if query != nil && query! != "" {
            updateResultList(query!)
        }
    }
    
    func performSuggestion(_ query: String) {
        if query.replacingOccurrences(of: " ", with: "").count == 0 {
            updateSuggestionList(words: [])
        }
        NSLog("Should asks for suggestion \(query)")
        
        let getParams: Parameters = [
            "q": query
        ]
        Alamofire.request(Eyulingo_UserUri.suggestionGetUri,
                          method: .get,
                          parameters: getParams)
        .responseSwiftyJSON(completionHandler: { responseJSON in
            if responseJSON.error == nil {
                let jsonResp = responseJSON.value
                if jsonResp != nil {
                    if jsonResp!["status"].stringValue == "ok" {
                        var suggestions: [String] = []
                        for goodsItem in jsonResp!["values"].arrayValue {
                            let suggest = goodsItem.string
                            if suggest != nil {
                                suggestions.append(suggest!)
                                if suggestions.count > 5 {
                                    break
                                }
                            }
                        }
                        self.updateSuggestionList(words: suggestions)
                        return
                    }
                }
            }
            self.updateSuggestionList(words: [])
        })
    }
    
    var resultGoods: [EyGoods] = []
    var isSearching: Bool = false
    var contentVC: DetailViewController?
    
    @IBOutlet weak var noContentIndicator: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: ModernSearchBar!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopLoading()
        searchBar.delegateModernSearchBar = self
        searchBar.searchDelegate = self
        searchBar.suggestionsView_searchIcon_isRound = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if contentVC == nil {
            if segue.identifier == "searchResultSegue" {
                contentVC = segue.destination as? DetailViewController
            }
        }
    }
    
    func updateSuggestionList(words: [String]) {
        searchBar.setDatas(datas: words)
        /// Forcefully raise a refresh, but only once
        searchBar.searchWhenUserTyping(caracters: searchBar.text ?? "", notAgain: true)
    }
    
    func updateResultList(_ query: String) {
        let getParams: Parameters = [
            "q": query
        ]
        self.resultGoods.removeAll()
        self.startLoading()
        var errorStr = "general error"
        Alamofire.request(Eyulingo_UserUri.searchGoodsGetUri,
                          method: .get, parameters: getParams)
        .responseSwiftyJSON(completionHandler: { responseJSON in
            if responseJSON.error == nil {
                let jsonResp = responseJSON.value
                if jsonResp != nil {
                    if jsonResp!["status"].stringValue == "ok" {
                        for goodsItem in jsonResp!["values"].arrayValue {
                            var tags: [String] = []
                            for tagItem in goodsItem["tags"].arrayValue {
                                tags.append(tagItem.stringValue)
                            }
//                            let c = goodsItem["price"].stringValue
//                            let d = Decimal(string: goodsItem["price"].stringValue)
                            self.resultGoods.append(EyGoods(goodsId: goodsItem["id"].int,
                                                            goodsName: goodsItem["name"].string,
                                                            coverId: goodsItem["image_id"].string,
                                                            description: goodsItem["description"].string,
                                                            storeId: goodsItem["store_id"].int,
                                                            storeName: goodsItem["store"].string,
                                                            storage: goodsItem["storage"].int,
                                                            price: Decimal(string: goodsItem["price"].stringValue),
                                                            couponPrice: Decimal(string: goodsItem["coupon_price"].stringValue),
                                                            tags: tags,
                                                            comments: []))
                        }
                        self.flushData()
                        self.contentVC?.keyWord = self.searchBar.text
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
            
            if errorStr == "account_locked" {
                self.makeAlert("搜索失败", "您的账户已被冻结。",
                                   completion: { self.stopLoading() })
            } else {
                self.makeAlert("搜索失败", "服务器报告了一个 “\(errorStr)” 错误。",
                        completion: { self.stopLoading() })
            }
        })
    }
    
    func flushData() {
        self.stopLoading()
        contentVC?.resultGoods = resultGoods
        contentVC?.reloadData()
    }
    
    func stopLoading() {
        loadingIndicator.isHidden = true
        if resultGoods.count == 0 {
            noContentIndicator.isHidden = false
            containerView.isHidden = true
        } else {
            noContentIndicator.isHidden = true
            containerView.isHidden = false
        }
    }
    
    func startLoading() {
        loadingIndicator.isHidden = false
        noContentIndicator.isHidden = true
        containerView.isHidden = true
    }

    
    ///Called if you use String suggestion list
    func onClickItemSuggestionsView(item: String) {
        print("User touched this item: " + item)
        searchBar.text = item
        searchBar.setShowsCancelButton(false, animated: true)
//        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        callRefresh(searchBar.text!)
    }
    
    ///Called when user touched shadowView
    func onClickShadowView(shadowView: UIView) {
        print("User touched shadowView")
    }
    
    func callRefresh(_ keyword: String) {
        updateResultList(keyword)
    }
}
