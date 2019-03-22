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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()

        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let email = Auth.auth().currentUser?.email
        let query = db.collection("users").document(email!).collection("tickets")
        self.listener =  query.addSnapshotListener { (documents, error) in
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
            self.tableView.reloadData()
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //Number of sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbTickets.count //Number of rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Instantiate custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let ticket: UserTicket //Creae empty ticket object
        ticket = dbTickets[indexPath.row] //Populate ticket object
        //Create date components
        let suffix = showFuncs.suffixFromTimestamp(timestamp: ticket.date)
        let date = showFuncs.timestampDateConverter(timestamp: ticket.date, format: "MMMM d")
        let year = showFuncs.timestampDateConverter(timestamp: ticket.date, format: " YYYY")
        
        cell.textLabel!.text = ticket.show //Use ticket's show attribute as cell title
        cell.detailTextLabel!.text = date + suffix + year //Display date components
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Transition to next view on selection of cell
        performSegue(withIdentifier: "toTicketDetailsView", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTicketDetailsView"
        {
            //Instantiate destination class
            let destinationVC = segue.destination as! TicketDetailsViewController
            //Get index of cell selected from tableview
            let indexPath = self.tableView.indexPathForSelectedRow
            //Use index to get ticket object associated with the selected cell
            let ticket = dbTickets[indexPath!.row]
            //Pass object to next view
            destinationVC.ticket = ticket
            destinationVC.showName = ticket.show
        }
    }
}
