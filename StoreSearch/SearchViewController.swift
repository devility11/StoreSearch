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
    
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //show the keyboard when the user start to type
        searchBar.becomeFirstResponder()
        //add a 64 point margin to the top, because we cant see the first cell
        //the searchbar is on the tableview
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        tableView.rowHeight = 80
        
        // we are registering the cell to the tableview
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
    }
    
    func iTunesUrl(searchText: String) -> URL {
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = URL(string: urlString)
        return url!
    }
    
    func performStoreRequest(with url: URL) -> String? {
        //because of the network loss or down, we are using the
        // do-try-catch block
        do {
            //we will pass back the data as a string
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download error: \(error)")
            return nil
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "there was an error during the json stuff", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }

    
    
}


func parse(dictionary: [String: Any]) -> [SearchResult] {
    guard let array = dictionary["results"] as? [Any] else {
        print("expected results array")
        return []
    }
    
    var searchResults = [SearchResult]()
    
    for resultDict in array {
        
        if let resultDict = resultDict as? [String: Any] {
            
            var searchResult: SearchResult?
            
            if let wrapperType = resultDict["wrapperType"] as? String {
                switch wrapperType {
                    case "track":
                        searchResult = parse(track: resultDict)
                    default:
                        break
                }
            }
            
            if let result = searchResult {
                searchResults.append(result)
            }
        }
    }
    return searchResults
}

func parse(track dictionary: [String: Any]) -> SearchResult {
    let searchResult = SearchResult()
    
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String
    if let price = dictionary["trackPrice"] as? Double {
        searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
        searchResult.genre = genre
    }
    return searchResult
}

func parse(json: String) -> [String: Any]? {
    //because the json data is a string, we have to put it into a data object
    // there is a chance that this tring to data conversion failed and because of this
    //we are using the guard
    // if lettol elteroen a guard visszaaad  egy nilt es nem all meg a program futasa
    guard let data = json.data(using: .utf8, allowLossyConversion: false)
        else {return nil}
    
    do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
        print("json error \(error)")
        return nil
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
        if !searchBar.text!.isEmpty {
            //this will hide the keyboard
            searchBar.resignFirstResponder()
            searchResults = []
            hasSearched = true
            
            let url = iTunesUrl(searchText: searchBar.text!)
            print("url: '\(url)'")
            
            if let jsonString = performStoreRequest(with: url) {
                print("MY json '\(jsonString)'")
                if let jsonDictionary = parse(json: jsonString){
                    print("dictionary \(jsonDictionary)")
                    parse(dictionary: jsonDictionary)
                    tableView.reloadData()
                    return
                }
            }
            showNetworkError()
        }
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
        
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel?.text = searchResult.name
            cell.artistNameLabel?.text = searchResult.artistName
            return cell
        }
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






