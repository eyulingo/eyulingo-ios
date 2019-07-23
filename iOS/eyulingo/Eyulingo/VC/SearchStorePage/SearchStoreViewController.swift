//
//  SearchStoreViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/9.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import Loaf
import SwiftyJSON
import UIKit

class SearchStoreViewController: UIViewController, ModernSearchBarDelegate, SearchDelegate, RefreshDelegate, SuicideDelegate {
    func callRefresh(handler: (() -> Void)?) {
        updateResultList(searchBar.text ?? "", completion: handler)
    }

    func killMe(lastWord: String) {
        let rootTabBarController = self.tabBarController as! RootTabBarViewController
        rootTabBarController.searchWord(keyWord: lastWord)
    }
    
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
            "q": query,
        ]
        Alamofire.request(Eyulingo_UserUri.storeSuggestionGetUri,
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

    var resultStores: [EyStore] = []
    var isSearching: Bool = false
    var contentVC: StoreResultViewController?

    @IBOutlet var noContentIndicator: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var searchBar: ModernSearchBar!
    @IBOutlet var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        stopLoading()
        searchBar.delegateModernSearchBar = self
        searchBar.searchDelegate = self
        searchBar.suggestionsView_searchIcon_isRound = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if contentVC == nil {
            if segue.identifier == "searchStoreResultSegue" {
                contentVC = segue.destination as? StoreResultViewController
                contentVC?.delegate = self
            }
        }
    }

    func updateSuggestionList(words: [String]) {
        searchBar.setDatas(datas: words)
        /// Forcefully raise a refresh, but only once
        searchBar.searchWhenUserTyping(caracters: searchBar.text ?? "", notAgain: true)
    }

    func updateResultList(_ query: String, completion: (() -> Void)? = nil) {
        let getParams: Parameters = [
            "q": query,
        ]
        resultStores.removeAll()
        startLoading()
        var errorStr = "general error"
        Alamofire.request(Eyulingo_UserUri.searchStoresGetUri,
                          method: .get, parameters: getParams)
            .responseSwiftyJSON(completionHandler: { responseJSON in
                if responseJSON.error == nil {
                    let jsonResp = responseJSON.value
                    if jsonResp != nil {
                        if jsonResp!["status"].stringValue == "ok" {
                            for storeItem in jsonResp!["values"].arrayValue {
//                            let c = goodsItem["price"].stringValue
//                            let d = Decimal(string: goodsItem["price"].stringValue)
                                self.resultStores.append(EyStore(storeId: storeItem["id"].intValue,
                                                                 coverId: storeItem["image_id"].stringValue,
                                                                 storeName: storeItem["name"].stringValue,
                                                                 storePhone: nil,
                                                                 storeAddress: storeItem["address"].stringValue,
                                                                 storeGoods: nil,
                                                                 storeComments: nil,
                                                                 distAvatarId: nil,
                                                                 distName: nil))
                            }
                            self.flushData()
                            self.contentVC?.keyWord = self.searchBar.text
                            completion?()
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
                Loaf("搜索失败。" + "服务器报告了一个 “\(errorStr)” 错误。", state: .error, sender: self).show()
                completion?()
            })
    }

    func flushData() {
        stopLoading()
        contentVC?.resultStores = resultStores
        contentVC?.reloadData()
    }

    func stopLoading() {
        let shouldShowNothing = resultStores.count == 0
        loadingIndicator.alpha = 1.0
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            self.loadingIndicator.alpha = 0.0
        }, completion: { _ in
            self.loadingIndicator.isHidden = true
            self.loadingIndicator.alpha = 1.0
        })

        if shouldShowNothing {
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

    /// Called if you use String suggestion list
    func onClickItemSuggestionsView(item: String) {
        print("User touched this item: " + item)
        searchBar.text = item
        searchBar.setShowsCancelButton(false, animated: true)
//        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        callRefresh(searchBar.text!)
    }

    /// Called when user touched shadowView
    func onClickShadowView(shadowView: UIView) {
        print("User touched shadowView")
    }

    func callRefresh(_ keyword: String) {
        updateResultList(keyword)
    }
}
