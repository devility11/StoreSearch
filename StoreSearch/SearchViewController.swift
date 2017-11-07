//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Norbert Czirjak on 2017. 11. 07..
//  Copyright © 2017. Norbert Czirjak. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var searchResults = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add a 64 point margin to the top, because we cant see the first cell
        //the searchbar is on the tableview
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        
        
    }
    
    
    
}

// MARK: searchBar delegate
extension SearchViewController: UISearchBarDelegate {
    //move the searchBar to the top
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    //handle the searchButton click events
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        //this will hide the keyboard
        searchBar.resignFirstResponder()
        for i in 0...2 {
            searchResults.append(String(format: "Fake result %d for '%@'", i, searchBar.text!))
        }
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.textLabel?.text = searchResults[indexPath.row]
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
}

