//  ShowListTableViewController.swift
//  Copyright © 2018 Seena Shafai. All rights reserved.

import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents.MaterialSnackbar

class ShowListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Variables
    var dateSortIndex = 0
    var nameSortIndex = 0
    var userIsAdmin: Bool?
    var swipeIndex: IndexPath?
    var blockStatsDict: [String: Any] = [:]
    var houseStatsDict: [String: Any] = [:]
    
    //MARK: - Initialise Firebase Properties
    var listener: ListenerRegistration!
    var dbShows = [Show]()
    var db: Firestore!
    var showFuncs = showFunctions()
    
    //MARK: - Search bar Properties
    var filteredShows = [Show]()
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
        if isFiltering() //If filtering is active
        {
            return filteredShows.count //Number of rows = number of shows in filtered array
        }
        return dbShows.count //Default: number of rows per section from full array
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
        
        //Timestamp-date conversion
        let timestamp: Timestamp = show.date
        let date: Date = timestamp.dateValue()
        //DateFormatter
        let dateFormatter = DateFormatter() //Initialise DateFormatter
        dateFormatter.dateFormat = "d MMMM, YYYY" //e.g. 2rd February, 2019
        let formattedDate = dateFormatter.string(from: date) //Format date using DateFormatter
        
        cell.cellNameLabel.text = show.name //Assign show name property to the cell name label
        cell.cellDescriptionLabel.text = formattedDate //Assign cell description label to new formatted date
        cell.cellImageView.image = UIImage(named: show.name + ".jpg") //Define image as the show name + 'jpg'
        
        return cell
    }
    
    @available(iOS 11.0, *) //Checking software version
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { (action, view, handler) in //Configure completion handler and define action to be carried out
            
            //Actions...
            self.swipeIndex = indexPath //Set var swipeIndex to index path of Swipe Action

            //Transition to 'Edit Show' view
            self.performSegue(withIdentifier: "toEditView", sender: nil)
            print("Edit Action Tapped")
        }
        
        editAction.backgroundColor = .red //Assign action bg colour
        
        let configuration: UISwipeActionsConfiguration! //Create configuration variable to be used within the selection statements
        if userIsAdmin == true
        {
            configuration = UISwipeActionsConfiguration(actions: [editAction]) //Assign configuration with previously defined edit action
        }
        else
        {
            configuration = UISwipeActionsConfiguration(actions: []) //Assign empty array to Swipe Action configuration
            //If the user is not an admin, no action is sent to the tableview cell, and therefore no edit options should be visible
        }
        return configuration //Return configuration bundle
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(90)
    }
    
    //MARK: - UISearchBar Methods
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (searchController.searchBar.text != "" || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredShows = dbShows.filter({( show : Show) -> Bool in //Closure: Begin filtering
            //Define category matching filter
            let doesCategoryMatch = (scope == "All") || (show.category == scope)
            //Validation for empty search bar
            if searchText == "" {
                return doesCategoryMatch
            } else {
                //Return show name if the category matches the scope selectors & contains search text
                return doesCategoryMatch && show.name.lowercased().contains(searchText.lowercased())
            }
        })
        //Refresh table for changes to show
        tableView.reloadData()
    }
    
    func getHouseBlockStats()
    {
        let houseStatsRef = db.collection("properties").document("houseStats")
        houseStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.houseStatsDict = document.data()!
            }
        }
        
        let blockStatsRef = db.collection("properties").document("blockStats")
        blockStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.blockStatsDict = document.data()!
            }
        }
    }
    
    //MARK: - Admin Settings
    @objc func adminSettingsTapped()
    {
        performSegue(withIdentifier: "toAddShow", sender: nil)
    }
    
    //MARK: - setSearchBarSettings
    private func setSearchBarSettings()
    {
        //Set scope button titles
        searchController.searchBar.scopeButtonTitles = ["All", "School", "House", "Independent"]
        //Set delegates
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        //Interface configuration
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shows"
        definesPresentationContext = true
        //Add physical search bar to navigation controller
        navigationItem.searchController = searchController
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
        db = Firestore.firestore()
        if userIsAdmin == true
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(adminSettingsTapped))
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(presentSortingActionSheet))
        }

        getHouseBlockStats()
        self.dateSortIndex = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self
        setSearchBarSettings()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove() //Remove database listener when view is dismissed
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Attach listener to database query at shows node
        self.listener =  db.collection("shows").addSnapshotListener { (documents, error) in
            guard let snapshot = documents else { //Validate response
                print("Error fetching documents results: \(error!)") //Output error if returned by API
                return
            }
            //Assign array to store QuerySnapshot mapping results
            let results = snapshot.documents.map { (document) -> Show in //CLOSURE
                if let show = Show(dictionary: document.data()) { //Instantiate object from DB dictionary
                    return show
                } else { //Return error message with details of raw data and Show class to find discrepencies
                    fatalError("Unable to initialize type \(Show.self) with dictionary \(document.data())")
                }
            }
            self.dbShows = results //Set show database to newly populated 'results' array
            self.tableView.reloadData() //Refresh table
        }
    }

    @objc func presentSortingActionSheet()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sort by Date", style: .default, handler: {(UIAlertAction) in
            self.bubbleSort()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Alphabetical Order", style: .default, handler: {(UIAlertAction) in
            self.sortByName()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        )
        
        self.present(alert, animated: true, completion: {
            print("completion")
        })
        
    }

    func bubbleSort()
    {
        let message = MDCSnackbarMessage() //Instantiate Snackbar object
        dateSortIndex = dateSortIndex + 1
        var dateArray = [Int]()//Initialise empty dateArray
        for i in 0..<dbShows.count { //Loop through shows
            dateArray.append(Int(dbShows[i].date.seconds)) //Add dates to dateArray
        }
        
        //Bubble Sort
        for i in 0..<dateArray.count { //Initiate first loop through date array
            for j in 1..<dateArray.count - i { //Initiate sub-loop through array
                //Date Index Checking
                if dateSortIndex % 2 == 0 { //Even Number ->
                    if dateArray[j] > dateArray[j-1] {//Compare consecutive values
                        let tmp = dateArray[j-1] //Swap: create temporary storage value
                        dateArray[j-1] = dateArray[j] //Swap: assign lower value as higher
                        dateArray[j] = tmp //Swap: assign higher value with temp value
                        message.text = "Sorted by ascending order: Most distant first " //Define Snackbar text
                        MDCSnackbarManager.show(message) //Show snackbar with text
                    }
                } else { //Odd Number ->
                    if dateArray[j] < dateArray[j-1] {//Compare consecutive values
                        let tmp = dateArray[j-1] //Swap: create temporary storage value
                        dateArray[j-1] = dateArray[j] //Swap: assign lower value as higher
                        dateArray[j] = tmp //Swap: assign higher value with temp value
                        message.text = "Sorted by descending order: Most recent first" //Define Snackbar text
                        MDCSnackbarManager.show(message) //Show snackbar with text
                    }
                }
            }
        }
        print(dateArray, "sorted") //Output sorted array
        reassignLocations(array: dateArray)
    }
    //Re-sort shows
    func reassignLocations(array: [Int]) //Take sorted date array as parameter
    {
        var sortedArray = [Show]() //Intialise empty array for sorting
        for i in 0..<(array.count) { //Iterate through sorted date array
            for j in 0..<(dbShows.count){ //Iterate through unsorted show array
                if array[i] == dbShows[j].date.seconds { //Compare sorted and unsorted values
                    sortedArray.append(dbShows[j]) //Append sorted values into array
                }
            }
        }
        dbShows = sortedArray //Populate show array with newly sorted shows
        tableView.reloadData() //Refresh table
    }
    
    func sortByName()
    {
        let message = MDCSnackbarMessage() //Instantiate Snackbar object
        nameSortIndex = nameSortIndex + 1 //Increment sort index
        if nameSortIndex % 2 == 0 //Check remainder after division
        {
            //Descending order
            dbShows = dbShows.sorted(by: { $0.name > $1.name })
            self.tableView.reloadData()//Refresh table
            message.text = "Displaying shows in reverse alphabetical order" //Define snackbar text
            MDCSnackbarManager.show(message) //Show snackbar with text
        }
        else
        {
            //Ascending order
            dbShows = dbShows.sorted(by: { $0.name < $1.name })
            self.tableView.reloadData() //Refresh table
            message.text = "Displaying shows in alphabetical order" //Define snackbar text
            MDCSnackbarManager.show(message) //Show snackbar with text
        }
    }
    
    // MARK: - Navigation
    //Prepare for segue method: called when segue requested
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEditView" //Compare identifiers
        {
            //Define destination view controller
            let destinationVC = segue.destination as! AddShowViewController
            destinationVC.edit = true //Assign edit value in next view
           
            //Cross-reference Swipe Action index of show with index of array of shows
            let show = dbShows[swipeIndex!.row]
            
            //Assign show variables to edit view
            destinationVC.show = show
        }
        
        if segue.identifier == "toAddShow" //Compare identifiers
        {
            let destinationVC = segue.destination as! AddShowViewController
            destinationVC.edit = false
        }
        if segue.identifier == "toDetailsView"
        {
            //Define next view to which the Show object is to be transferred
            let destinationVC = segue.destination as! ShowDetailViewController
            //Locate show object from show array
            let indexPath = self.tableView.indexPathForSelectedRow
            let show = dbShows[indexPath!.row]
            //Assign show object to variable in the new view
            destinationVC.showTitle = show.name
            destinationVC.show = show
            
        }
    }
}

extension ShowListTableViewController: UISearchResultsUpdating {
    //MARK: - UISearchResultsUpdatingDelegate
    func updateSearchResults(for searchController: UISearchController) {
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
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


