//
//  AdminShowListTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 01/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents.MaterialSnackbar

class AdminShowListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Variables
    var dateSortIndex = 0
    var nameSortIndex = 0
    
    //MARK: - Initialise Firebase Properties
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var dbShows = [Show]()
    var db: Firestore!
    
    
    //MARK: - Search bar Properties
    var filteredShows = [Show]()
    var showFuncs = showFunctions()
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - IB Links
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func sortTableAction(_ sender: Any) {
        presentSortingActionSheet()
    }
    
    // MARK: - TableView Datasource
    
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
    
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowListTableViewCell
        let show: Show
        if isFiltering() {
            show = filteredShows[indexPath.row]
        } else {
            show = dbShows[indexPath.row]
        }
        cell.cellNameLabel.text = show.name
        _ = Date(timeIntervalSince1970: TimeInterval(show.date.seconds))
        let medDate = showFuncs.getDateFromEpoch(timeInterval: TimeInterval(show.date.seconds))
        
        cell.cellDescriptionLabel.text = medDate
        cell.cellImageView.image = UIImage(named: show.name + ".jpg")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(90)
    }
    
    //MARK: - UISearchBar Methods
    
    //Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
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
    
    //MARK: - setSearchBarSettings
    private func setSearchBarSettings()
    {
        searchController.searchBar.scopeButtonTitles = ["All", "School", "House", "Independent"]
        searchController.searchBar.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shows"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    //MARK: - Firebase Queries
    fileprivate func baseQuery() -> Query{
        return db.collection("shows").limit(to: 50)
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
            }
        }
    }
    
    //MARK: - setFirebaseSettings
    func setFirebaseSettings()
    {
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        settings.isPersistenceEnabled = false
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateSortIndex = 0
        setFirebaseSettings()
        self.query = baseQuery()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        setSearchBarSettings()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Show in
                if let show = Show(dictionary: document.data()) {
                    return show
                } else {
                    fatalError("Unable to initialize type \(Show.self) with dictionary \(document.data())")
                }
            }
            
            self.dbShows = results
            self.documents = snapshot.documents
            self.tableView.reloadData()
            
        }
    }
    
    func presentSortingActionSheet()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sort by Date", style: .default, handler: {(UIAlertAction) in
            self.sortByDate()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Alphabetical Order", style: .default, handler: {(UIAlertAction) in
            self.sortByName()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Rating", style: .default, handler: {(UIAlertAction) in
            print("rate")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        )
        
        self.present(alert, animated: true, completion: {
            print("completion")
        })
        
    }
    
    func sortByDate()
    {
        let message = MDCSnackbarMessage()
        dateSortIndex = dateSortIndex + 1
        if dateSortIndex % 2 != 0
        {
            dbShows = dbShows.sorted(by: { $0.date.seconds < $1.date.seconds })
            self.tableView.reloadData()
            message.text = "Displaying oldest shows first"
            MDCSnackbarManager.show(message)
        }
        else
        {
            dbShows = dbShows.sorted(by: { $0.date.seconds > $1.date.seconds })
            self.tableView.reloadData()
            message.text = "Displaying upcoming shows first"
            MDCSnackbarManager.show(message)
        }
    }
    
    func sortByName()
    {
        let message = MDCSnackbarMessage()
        nameSortIndex = nameSortIndex + 1
        if nameSortIndex % 2 == 0
        {
            dbShows = dbShows.sorted(by: { $0.name > $1.name })
            self.tableView.reloadData()
            message.text = "Displaying shows in reverse alphabetical order"
            MDCSnackbarManager.show(message)
        }
        else
        {
            dbShows = dbShows.sorted(by: { $0.name < $1.name })
            self.tableView.reloadData()
            message.text = "Displaying shows in alphabetical order"
            MDCSnackbarManager.show(message)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsView"
        {
            let destinationVC = segue.destination as! ShowDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let show = dbShows[indexPath!.row]
            destinationVC.showTitle = show.name
        }
    }
}

extension AdminShowListTableViewController: UISearchResultsUpdating {
    //MARK: - UISearchResultsUpdatingDelegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension AdminShowListTableViewController: UISearchBarDelegate {
    //MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
