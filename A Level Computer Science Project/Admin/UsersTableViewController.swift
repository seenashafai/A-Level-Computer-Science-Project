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
    
    //MARK: - Initialise Firebase Properties
    var listener: ListenerRegistration!
    var dbUsers = [User]()
    var db: Firestore!
    var showFuncs = showFunctions()
    
    
    @IBAction func sortTableAction(_ sender: Any) {
        presentSortingActionSheet()
    }
    
    //TableView datasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //Number of sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbUsers.count //Number of rows
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(90)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        let user: User! //Define empty user variable
        user = dbUsers[indexPath.row] //Retrieve user relating to specific cell
        cell.cellNameLabel.text = String(user.firstName + " " + user.lastName) //Concatenating first and last name
        cell.cellDescriptionLabel.text = String(user.house + ", " + user.block + " Block") //Concatenating house and block
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toUserDetails", sender: nil)
    }
    
    
    
    @objc func presentSortingActionSheet()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sort by Alphabetical Order", style: .default, handler: {(UIAlertAction) in
            self.sortByName()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Define query as 'users' node
        let query = db.collection("users")
        self.listener =  query.addSnapshotListener { (documents, error) in //Attach listener to query
            guard let snapshot = documents else { //Validate returned snapshot
                print("Error fetching documents results: \(error!)") //Output error
                return //Exit function
            }
            //Handle results
            let results = snapshot.documents.map { (document) -> User in //Map results to user class
                if let user = User(dictionary: document.data()) { //Validate that user class maps correctly
                    return user //Return new user object
                } else { //Dictionary initialisation failed
                    fatalError("Unable to initialize type \(User.self) with dictionary \(document.data())")
                }
            }
            //Handle results locally
            self.dbUsers = results
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        print("listener removed")
    }
    
    //MARK: - Navigation
    
    //Pass user information on to next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserDetails" //Validate the segue
        {
            let indexPath = self.tableView.indexPathForSelectedRow //Get index of selected row
            let user = dbUsers[indexPath!.row] //Reference user object from row index
            //Instantiate incoming class
            let destinationVC = segue.destination as! UserDetailsViewController
            //Assign user object to incoming view
            destinationVC.user = user
        }
    }
}
