//
//  CollectionViewController.swift
//  collectionViewWithSearchBar
//
//  Created by Homam on 23/12/15.
//  Copyright © 2015 Homam. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UISearchBarDelegate {
    var dataSource: [String]?
    var dataSourceForSearchResult: [String]?
    var searchBarActive: Bool = false
    var searchBarBoundsY: CGFloat?
    var searchBar: UISearchBar?
    var refreshControl: UIRefreshControl?
    let reuseIdentifier: String = "Cell"

    override func viewDidLoad() {
        dataSource = ["Modesto", "Rebecka", "Andria", "Sergio", "Robby", "Jacob", "Lavera", "Theola", "Adella", "Garry", "Lawanda", "Christiana", "Billy", "Claretta", "Gina", "Edna", "Antoinette", "Shantae", "Jeniffer", "Fred", "Phylis", "Raymon", "Brenna", "Gulfs", "Ethan", "Kimbery", "Sunday", "Darrin", "Ruby", "Babette", "Latrisha", "Dewey", "Della", "Dylan", "Francina", "Boyd", "Willette", "Mitsuko", "Evan", "Dagmar", "Cecille", "Doug",
                      "Jackeline", "Yolanda", "Patsy", "Haley", "Isaura", "Tommye", "Katherine", "Vivian"]

        dataSourceForSearchResult = [String]()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareUI()
    }

    deinit {
        self.removeObservers()
    }

    // MARK: actions

    @objc func refreshControlAction() {
        cancelSearching()

        DispatchQueue.main.async {
            // stop refreshing after 2 seconds
            self.collectionView?.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: <UICollectionViewDataSource>

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBarActive {
            return dataSourceForSearchResult!.count
        }
        return dataSource!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell

        if searchBarActive {
            cell.textField.text = dataSourceForSearchResult![indexPath.row]
        } else {
            cell.textField.text = dataSource![indexPath.row]
        }

        return cell
    }

    // MARK: <UICollectionViewDelegateFlowLayout>

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: searchBar!.frame.size.height, left: 0, bottom: 0, right: 0)
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellLeg = (collectionView.frame.size.width / 2) - 5
        return CGSize(width: cellLeg, height: cellLeg)
    }

    // MARK: Search

    func filterContentForSearchText(searchText: String) {
        dataSourceForSearchResult = dataSource?.filter({ (text: String) -> Bool in
            text.contains(searchText)
        })
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // user did type something, check our datasource for text that looks the same
        if searchText.count > 0 {
            // search and reload data source
            searchBarActive = true
            filterContentForSearchText(searchText: searchText)
            collectionView?.reloadData()
        } else {
            // if text lenght == 0
            // we will consider the searchbar is not active
            searchBarActive = false
            collectionView?.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearching()
        collectionView?.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarActive = true
        view.endEditing(true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        self.searchBar!.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        searchBarActive = false
        self.searchBar!.setShowsCancelButton(false, animated: false)
    }

    func cancelSearching() {
        searchBarActive = false
        searchBar!.resignFirstResponder()
        searchBar!.text = ""
    }

    // MARK: prepareVC

    func prepareUI() {
        addSearchBar()
        addRefreshControl()
    }

    func addSearchBar() {
        if searchBar == nil {
            searchBarBoundsY = (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height

            searchBar = UISearchBar(frame: CGRect(x: 0, y: searchBarBoundsY!, width: UIScreen.main.bounds.size.width, height: 44))
            searchBar!.searchBarStyle = UISearchBar.Style.minimal
            searchBar!.tintColor = UIColor.white
            searchBar!.barTintColor = UIColor.white
            searchBar!.delegate = self
            searchBar!.placeholder = "search here"

            addObservers()
        }

        if !searchBar!.isDescendant(of: view) {
            view.addSubview(searchBar!)
        }
    }

    func addRefreshControl() {
        if refreshControl == nil {
            refreshControl = UIRefreshControl()
            refreshControl?.tintColor = UIColor.white
            refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: UIControl.Event.valueChanged)
            
        }
        if !refreshControl!.isDescendant(of: collectionView!) {
            collectionView!.addSubview(refreshControl!)
        }
    }

    func startRefreshControl() {
        if !refreshControl!.isRefreshing {
            refreshControl!.beginRefreshing()
        }
    }

    func addObservers() {
        let context = UnsafeMutablePointer<UInt8>(bitPattern: 1)
        collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: context)
    }

    func removeObservers() {
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath! == "contentOffset" {
            if let collectionV: UICollectionView = object as? UICollectionView {
                searchBar?.frame = CGRect(
                    x: searchBar!.frame.origin.x,
                    y: searchBarBoundsY! + ((-1 * collectionV.contentOffset.y) - searchBarBoundsY!),
                    width: searchBar!.frame.size.width,
                    height: searchBar!.frame.size.height
                )
            }
        }
    }
}
