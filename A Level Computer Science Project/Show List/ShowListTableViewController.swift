//
//  ShowListTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 17/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ShowListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Variables

    //MARK: - FirebaseT2
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var dbShows = [Show]()


    var db: Firestore!
    var filteredShows = [Show]()
    
    //MARK: - Properties
    var showFuncs = showFunctions()
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
        _ = Date(timeIntervalSince1970: TimeInterval(show.date.seconds))
        let medDate = showFuncs.getDateFromEpoch(timeInterval: TimeInterval(show.date.seconds))
        
        cell.cellDescriptionLabel.text = medDate
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
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        settings.isPersistenceEnabled = false


        self.query = baseQuery()
        
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
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
            self.sort()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Alphabetical Order", style: .default, handler: {(UIAlertAction) in
            self.sort()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Rating", style: .default, handler: {(UIAlertAction) in
            self.sort()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        )
        
        self.present(alert, animated: true, completion: {
            print("completion")
        })
        
    }
    /*
    func pullFromFirestore()
    {
        db.collection("shows").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    var dict = document.data()
                    self.dbShowArray.append(dict)
                    print(self.dbShowArray, "showArray")
                }
            }
        }

    }
 */
    
    func sort()
    {
        dbShows = dbShows.sorted(by: { $0.date.seconds < $1.date.seconds })
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

extension Array where Element == [String:String] {
    func sorted(by key: String) -> [[String:String]] {
        return sorted { $0[key] ?? "" < $1[key] ?? "" }
    }
}
