//
//  SearchViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/9.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import ModernSearchBar
import Parchment

class SearchViewController: UIViewController, ModernSearchBarDelegate {
    
    @IBOutlet weak var searchBar: ModernSearchBar!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegateModernSearchBar = self
        
        let suggestionList = ["Onions", "Canary", "Chile", "Salary", "Minority", "Parliament"]
        self.searchBar.setDatas(datas: suggestionList)
        self.searchBar.suggestionsView_searchIcon_isRound = false
    }

    
    ///Called if you use String suggestion list
    func onClickItemSuggestionsView(item: String) {
        print("User touched this item: " + item)
        self.searchBar.text = item
    }
    
    ///Called when user touched shadowView
    func onClickShadowView(shadowView: UIView) {
        print("User touched shadowView")
    }
}
