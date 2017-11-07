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
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
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
        
        if searchBar.text! != "justin" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        hasSearched = true
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }else if searchResults.count == 0 {
            return 1
        }else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if searchResults.count == 0 {
            cell.textLabel?.text = "Nothing found"
            cell.detailTextLabel?.text = ""
        }else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel?.text = searchResult.name
            cell.detailTextLabel?.text = searchResult.artistName
        }
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    //remove the grey color from the selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // you can select only rows where you have a value
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        }else{
            return indexPath
        }
    }
    
}

