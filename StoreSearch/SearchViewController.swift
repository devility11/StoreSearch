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
    var isLoading = false
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
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
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
    }
    
    func iTunesUrl(searchText: String) -> URL {
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = URL(string: urlString)
        return url!
    }
    
    /*
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
    }*/
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "there was an error during the json stuff", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
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
    
    func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        return searchResult
    }
    
    
    
    func parse(audiobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    
    
    func parse(json data: Data) -> [String: Any]? {
        //because the json data is a string, we have to put it into a data object
        // there is a chance that this tring to data conversion failed and because of this
        //we are using the guard
        // if lettol elteroen a guard visszaaad  egy nilt es nem all meg a program futasa
        //guard let data = json.data(using: .utf8, allowLossyConversion: false)
          //  else {return nil}
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("json error \(error)")
            return nil
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
                    case "audiobook":
                        searchResult = parse(audiobook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                    default:
                        break
                    }
                }else if let kind = resultDict["kind"] as? String, kind == "ebook" {
                    searchResult = parse(ebook: resultDict)
                }
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
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
            
            isLoading = true
            tableView.reloadData()
            
            searchResults = []
            hasSearched = true
            
            let url = self.iTunesUrl(searchText: searchBar.text!)
            //also an async process
            let session = URLSession.shared
            // datatask is for sending https get requests to the server url
            let dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                if let error = error {
                    print("errro \(error)")
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data, let jsonDictionary = self.parse(json: data) {
                        self.searchResults = self.parse(dictionary: jsonDictionary)
                        self.searchResults.sort(by: { result1, result2 in
                            return result1.name.localizedStandardCompare(result2.name) == .orderedAscending
                        })
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                        
                    }
                } else {
                    print("response \(response!)")
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
                
            })
            //we need the resume to start the closure code
            dataTask.resume()
            
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 1
        }else if !hasSearched {
            return 0
        }else if searchResults.count == 0 {
            return 1
        }else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel?.text = searchResult.name
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
            }
            
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
        if searchResults.count == 0 || isLoading {
            return nil
        }else{
            return indexPath
        }
    }
    
}


func kindForDisplay(_ kind: String) -> String {
    switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
    }
}





