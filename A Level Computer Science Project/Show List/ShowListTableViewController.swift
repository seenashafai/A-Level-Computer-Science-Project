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
import MaterialComponents.MaterialSnackbar
import PKHUD

class ShowListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Variables
    var dateSortIndex = 0
    var nameSortIndex = 0
    var userIsAdmin: Bool?
    
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

        let medDate = showFuncs.getDateFromEpoch(timeInterval: TimeInterval(show.date.seconds))
        
        cell.cellDescriptionLabel.text = medDate
        cell.cellImageView.image = UIImage(named: show.name + ".jpg")
        
        return cell
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "Add") { (action, view, handler) in
            print("Add Action Tapped")
            HUD.flash(HUDContentType.systemActivity, delay: 1.5)
            
            HUD.flash(HUDContentType.success)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        deleteAction.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Delete Action Tapped")
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
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
    
    //MARK: - Admin Settings
    @objc func adminSettingsTapped()
    {
        print("epic admin time")
        performSegue(withIdentifier: "toAddShow", sender: nil)
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
    }
    
    func resetShowStatistics()
    {
        let seatsArray = arrayGen()
        let ticketAvailabilityRef = db.collection("shows").document(ticketShowTitle).collection(String(dateIndex)).document("statistics")
        print(ticket)
        print(seatsArray, "seats")
        print(user.getCurrentUserEmail(), "currentUserEmail")
        print("availableTickets", ticket[0].availableTickets)
        ticketAvailabilityRef.updateData([
            "availableSeats": seatsArray, // generate new seating chart
            "availableTickets": ticket[0].availableTickets - numberOfTickets!,
            "numberOfTicketHolders": ticket[0].numberOfTicketHolders + 1,
            "ticketHolders": FieldValue.arrayUnion([user.getCurrentUserEmail()])
        ])  { err in
            if err != nil {
                print("error", err?.localizedDescription)
            } else
            {
                print("success")
                self.performSegue(withIdentifier: "toSeatSelection", sender: nil)
            }
        }
        print("bobby")
    }
    
    func arrayGen() -> [Int]
    {
        var seatsArray = [Int]()
        for i in 0..<100
        {
            seatsArray.append(i)
        }
        print(seatsArray)
        return seatsArray
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userIsAdmin, "admin")

        self.dateSortIndex = 0
        setFirebaseSettings()
        self.query = baseQuery()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        setSearchBarSettings()
        if userIsAdmin == true
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(adminSettingsTapped))
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(presentSortingActionSheet))
        }
        
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

    @objc func presentSortingActionSheet()
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
            destinationVC.show = show
            
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
