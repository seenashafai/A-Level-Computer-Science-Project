//
//  UsersTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 18/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD
import MaterialComponents.MaterialSnackbar

class UsersTableViewController: UITableViewController {

    //MARK: - Properties
    var nameSortIndex = 0
    var ticketSortIndex = 0
    var userShowsArray: [String]?
    var showCount: Int!
    
    //MARK: - Initialise Firebase Properties
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var dbUsers = [User]()
    var db: Firestore!
    var showFuncs = showFunctions()
    
    //MARK: - Search bar Properties
    var filteredUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBAction func sortTableAction(_ sender: Any) {
        presentSortingActionSheet()
    }
    
    //MARK: - TableView Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering()
        {
            return filteredUsers.count
        }
        return dbUsers.count
    }

    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        let user: User
        if isFiltering() {
            user = filteredUsers[indexPath.row]
        } else {
            user = dbUsers[indexPath.row]
        }
        //cell.cellNameLabel.text = user.firstName
        
        return cell
    }
    
    //MARK: - Searchbar Delegate
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredUsers = dbUsers.filter({( user : User) -> Bool in
            let doesCategoryMatch = (scope == "All") || (user.block == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                let fullName: String = (user.firstName + user.lastName)
                return doesCategoryMatch && fullName.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    
    
    @objc func presentSortingActionSheet()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sort by Alphabetical Order", style: .default, handler: {(UIAlertAction) in
            self.sortByName()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Plays Booked", style: .default, handler: {(UIAlertAction) in
            print("rate")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        )
        
        self.present(alert, animated: true, completion: {
            print("completion")
        })
    }
    
    func sortByName()
    {
        let message = MDCSnackbarMessage()
        nameSortIndex = nameSortIndex + 1
        if nameSortIndex % 2 == 0
        {
            dbUsers = dbUsers.sorted(by: { $0.lastName > $1.lastName })
            self.tableView.reloadData()
            message.text = "Displaying users in reverse alphabetical order"
            MDCSnackbarManager.show(message)
        }
        else
        {
            dbUsers = dbUsers.sorted(by: { $0.lastName < $1.lastName })
            self.tableView.reloadData()
            message.text = "Displaying users in alphabetical order"
            MDCSnackbarManager.show(message)
        }
    }
    
    func sortByPlaysBooked()
    {
        let message = MDCSnackbarMessage()
        ticketSortIndex = ticketSortIndex + 1
        if ticketSortIndex % 2 == 0
        {
            dbUsers = dbUsers.sorted(by: { $0.ticketsBooked > $1.ticketsBooked })
            self.tableView.reloadData()
            message.text = "Displaying users in descending order of shows booked"
            MDCSnackbarManager.show(message)
        }
        else
        {
            dbUsers = dbUsers.sorted(by: { $0.ticketsBooked < $1.ticketsBooked })
            self.tableView.reloadData()
            message.text = "Displaying users in ascending order of shows booked"
            MDCSnackbarManager.show(message)
        }
    }

    func getUserShowStats()
    {
        let indexPath = self.tableView.indexPathForSelectedRow
        let user = dbUsers[indexPath!.row]
        let userShowRef = db.collection("users").document(user.emailAddress).collection("tickets")
        userShowRef.getDocuments() {(querySnapshot, err) in
            if let err = err
            {
                print("Error getting documents: \(err)");
            }
            else
            {
                for document in querySnapshot!.documents {
                    self.showCount += 1
                    self.userShowsArray?.append(document.data()["show"] as! String)
                    print("\(document.documentID) => \(document.data())");
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.query = baseQuery()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    

    //MARK: - Firebase Queries
    fileprivate func baseQuery() -> Query{
        return db.collection("users").limit(to: 50)
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> User in
                if let user = User(dictionary: document.data()) {
                    return user
                } else {
                    fatalError("Unable to initialize type \(User.self) with dictionary \(document.data())")
                }
            }
            
            self.dbUsers = results
            self.documents = snapshot.documents
            self.tableView.reloadData()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        print("listener removed")
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UsersTableViewController: UISearchResultsUpdating {
    //MARK: - UISearchResultsUpdatingDelegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension UsersTableViewController: UISearchBarDelegate {
    //MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
