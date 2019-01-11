//
//  TicketsTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 10/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import MaterialComponents.MaterialSnackbar
import PKHUD

class TicketsTableViewController: UITableViewController {

    //MARK: - Initialise Firebase Properties
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var dbTickets = [UserTicket]()
    var db: Firestore!
    var showFuncs = showFunctions()
    var user = FirebaseUser()
    
    
    
    //MARK: - Firebase Queries
    fileprivate func baseQuery() -> Query{
        let email = user.getCurrentUserEmail()
        return db.collection("users").document(email).collection("tickets")
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
            }
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
            
            let results = snapshot.documents.map { (document) -> UserTicket in
                if let ticket = UserTicket(dictionary: document.data()) {
                    return ticket
                } else {
                    fatalError("Unable to initialize type \(UserTicket.self) with dictionary \(document.data())")
                }
            }
            
            self.dbTickets = results
            self.documents = snapshot.documents
            self.tableView.reloadData()
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.query = baseQuery()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dbTickets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TicketTableViewCell
        let ticket: UserTicket
        ticket = dbTickets[indexPath.row]
        
        cell.cellNameLabel.text = ticket.show
        cell.cellDescriptionLabel.text = ticket.date
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTicketDetailsView", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTicketDetailsView"
        {
            let destinationVC = segue.destination as! TicketDetailsViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let ticket = dbTickets[indexPath!.row]
            destinationVC.ticket = ticket
            destinationVC.showName = ticket.show
        }
    }
}
