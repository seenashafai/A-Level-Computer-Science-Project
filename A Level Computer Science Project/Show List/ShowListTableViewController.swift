//
//  ShowListTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 17/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class ShowListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Properties
    var shows = [Show]()
    //SearchController setup
    let searchController = UISearchController(searchResultsController: nil)
    var filteredShows = [Show]() //Array to hold shows being searched
    
    //MARK: - IB Links
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //Number of sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() //If filtering is active (i.e. searchBar is in use)
        {
            return filteredShows.count //Number of rows = number of shows in filtered array
        }
        return shows.count //Number of rows per section
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Define custom cell with a reusable identifier so it can be repeated across the TableView
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowListTableViewCell
        //Above: assigning custom cell type to 'ShowListTableViewCell' to the cell definition
        let show: Show //Define emtpy Show object
        if isFiltering() //Check if filtering is active (i.e. searchBar is in use)
        {
            show = filteredShows[indexPath.row] //Retrieve show object from filtered show array with cell index
        } else {
            show = shows[indexPath.row]//Retrieve show object from full show array with cell index
        }
        cell.cellNameLabel.text = show.name //Assign show name property to the cell name label
        cell.cellDescriptionLabel.text = show.date //Assign show dat property to cell description label
        cell.cellImageView.image = UIImage(named: show.name + ".jpg") //Define image name as the show name + 'jpg'
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(90)
    }
    
    //MARK: - Private instance methods
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String) {
        filteredShows = shows.filter({( show : Show) -> Bool in //Closure: Begin filtering
            print("Filtering executed") //TRACE
            //Define cateory matching filter
            let categoryMatch = (scope == "All") || (show.category == scope + " Play")
            
            //Validation for empty search bar
            if searchText == "" {
                print("search text empty") //TRACE
                return categoryMatch
            } else {
                //Return show name if the category matches the scope selectors & contains search text
                print("Category matches and filter succeeded") //TRACE
                return categoryMatch && show.name.lowercased().contains(searchText.lowercased())
            }
        })
        //Refresh table for changes to show
        print("tableView refreshed") //TRACE
        tableView.reloadData()
        print(filteredShows, "filteredShows array")
    }
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set TableView delegate & data source
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //SearchController Config
        
        //Set Scope button titles
        searchController.searchBar.scopeButtonTitles = ["All", "School", "House", "Independent"]
        //Set delegates
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        //Interface variables
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shows"
        definesPresentationContext = true
        
        //Manually add search bar to navigation bar
        navigationItem.searchController = searchController
        
        shows = [
            Show(name: "Othello", category: "School Play", date: "23rd-25th December"),
            Show(name: "Macbeth", category: "House Play", date: "6th-8th January"),
            Show(name: "Twelfth Night", category: "Independent Play", date: "15th-17th January"),
            Show(name: "Romeo & Juliet", category: "School Play", date: "1st-3rd February")
        ]
    }
}

extension ShowListTableViewController: UISearchResultsUpdating {
    //MARK: - UISearchResultsUpdatingDelegate
    func updateSearchResults(for searchController: UISearchController) {
        print("Text entered into search bar")
        let searchBar = searchController.searchBar
        //Define scope from searchBar attributes
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        //Filter content as a result of search input changing
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension ShowListTableViewController: UISearchBarDelegate {
    //MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //Filter content as a result of scope button changing index
        print("Scope button changed")
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
