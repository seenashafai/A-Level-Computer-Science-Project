//
//  ShowListTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 17/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ShowListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Variables
    /*
    var showArray = ["Othello", "Macbeth", "Twelfth Night", "Romeo & Juliet"]
    var showDateArray = ["23rd-25th December", "6th-8th January", "15th-17th January", "1st-3rd Feburary"]
    var avgDateArray = ["24 Dec 2017", "7 Jan 2018", "16 Jan 2018", "2 Feb 2018"]
    var convertedDateArray: [Date] = []
 */
    var dbShowArray = [Any]()

    
    //MARK: - Firebase Variables
    //var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    
    var dbShows = [Show]()
    


    var db: Firestore!
    var filteredShows = [Show]()
    
    //MARK: - Properties
    var shows = [Show]()
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - IB Links
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func sortTableAction(_ sender: Any) {
        presentSortingActionSheet()
    }
    
    // MARK: - TableView Delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering()
        {
            return filteredShows.count
        }
        
        return dbShows.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowListTableViewCell
        let show: Show
        if isFiltering() {
            show = filteredShows[indexPath.row]
        } else {
            show = dbShows[indexPath.row]
        }
        cell.cellNameLabel.text = show.name
        cell.cellDescriptionLabel.text = String(show.date.dateValue().description)
        cell.cellImageView.image = UIImage(named: show.name + ".jpg")
        
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
        filteredShows = dbShows.filter({( show : Show) -> Bool in
            let doesCategoryMatch = (scope == "All") || (show.category == scope)
            
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
        
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        searchController.searchBar.scopeButtonTitles = ["All", "School", "House", "Independent"]
        searchController.searchBar.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shows"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    //View dismissed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Remove listener
        self.listener.remove()
    }
    
    //View instantiated
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Attach listener to view
        self.listener =  db.collection("shows").addSnapshotListener { (documents, error) in //Begin closure
            guard let snapshot = documents else { //Validate snapshot
                print("Error fetching documents results: \(error!)") //Provide Firestore error message
                return
            }
            
            //Assign array to store QuerySnapshot mapping results
            let results = snapshot.documents.map { (document) -> Show in //CLOSURE
                //Validation
                if let show = Show(dictionary: document.data()) { //Instantiate show object from DB dictionary
                    return show
                } else {
                    //Return error message, details of raw data and Show class to find discrepencies
                    fatalError("Unable to initialize type \(Show.self) with dictionary \(document.data())")
                }
            }
            self.dbShows = results //Set show database to newly populated 'results' array
            self.tableView.reloadData() //Refresh table
        }
    }

    func presentSortingActionSheet()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sort by Date", style: .default, handler: {(UIAlertAction) in
            //self.sort()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Alphabetical Order", style: .default, handler: {(UIAlertAction) in
            //self.sort()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Rating", style: .default, handler: {(UIAlertAction) in
            //self.sort()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        )
        
        self.present(alert, animated: true, completion: {
            print("completion")
        })
        
    }
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
