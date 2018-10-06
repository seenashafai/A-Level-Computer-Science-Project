//
//  ShowListTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 17/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class ShowListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Variables
    
    var showArray = ["Othello", "Macbeth", "Twelfth Night", "Romeo & Juliet"]
    var showDateArray = ["23rd-25th December", "6th-8th January", "15th-17th January", "1st-3rd Feburary"]
    var filteredShows = [Show]()
    
    //MARK: - Properties
    var shows = [Show]()
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - IB Links
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - TableView Delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering()
        {
            return filteredShows.count
        }
        
        return shows.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowListTableViewCell
        let show: Show
        if isFiltering() {
            show = filteredShows[indexPath.row]
        } else {
            show = shows[indexPath.row]
        }
        cell.cellNameLabel.text = show.name
        cell.cellDescriptionLabel.text = show.date
        cell.cellImageView.image = UIImage(named: show.name + ".jpg")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(90)
    }
    
    //MARK: - UISearchBarDelegate
    
    //MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredShows = shows.filter({( show : Show) -> Bool in
            let doesCategoryMatch = (scope == "All") || (show.category == scope + " Play")
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && show.name.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        searchController.searchBar.scopeButtonTitles = ["All", "School", "House", "Independent"]
        searchController.searchBar.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shows"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        shows = [
            Show(name: "Othello", category: "School Play", date: "23rd-25th December"),
            Show(name: "Macbeth", category: "School Play", date: "6th-8th January"),
            Show(name: "Twelfth Night", category: "School Play", date: "15th-17th January"),
            Show(name: "Romeo & Juliet", category: "School Play", date: "1st-3rd February")
        ]
    }

    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShowListTableViewController: UISearchResultsUpdating {
    //MARK: - UISearchResultsUpdatingDelegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension ShowListTableViewController: UISearchBarDelegate {
    //MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
