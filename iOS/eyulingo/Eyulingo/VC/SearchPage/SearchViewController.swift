//
//  SearchViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/9.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import ModernSearchBar

class SearchViewController: UIViewController, ModernSearchBarDelegate {
    
    @IBOutlet weak var searchBar: ModernSearchBar!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegateModernSearchBar = self
        
        let suggestionList = ["Onions", "Canary", "Chile", "Salary", "Minority", "Parliament"]
        searchBar.setDatas(datas: suggestionList)
        searchBar.suggestionsView_searchIcon_isRound = false
    }

    
    ///Called if you use String suggestion list
    func onClickItemSuggestionsView(item: String) {
        print("User touched this item: " + item)
        searchBar.text = item
        searchBar.resignFirstResponder()
        callRefresh(searchBar.text!)
    }
    
    ///Called when user touched shadowView
    func onClickShadowView(shadowView: UIView) {
        print("User touched shadowView")
    }
    
    func callRefresh(_ keyword: String) {
        
    }
}
