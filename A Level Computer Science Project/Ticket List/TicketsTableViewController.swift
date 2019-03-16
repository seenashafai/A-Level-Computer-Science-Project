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
import MaterialComponents.MaterialSnackbar
import PKHUD

class TicketsTableViewController: UITableViewController {

    //Database Properties
    var listener: ListenerRegistration!
    var db: Firestore!

    //Local Properties
    var dbTickets = [UserTicket]()
    
    //Class Instances
    var showFuncs = showFunctions()
    var user = FirebaseUser()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let email = user.getCurrentUserEmail() //Get user's email
        let query = db.collection("users").document(email).collection("tickets") //Query user's email in DB
        //Add listener to query
        self.listener =  query.addSnapshotListener { (documents, error) in
            //Validate data...
            guard let snapshot = documents else { //Handle errors
                //Output error
                print("Error fetching documents results: \(error!)")
                return //Exit function
            }
            
            //Handle results - Map resulting object into the UserTicket dictionary
            let results = snapshot.documents.map { (document) -> UserTicket in
                //Convert the new object into my UserTicket dictionary...
                if let ticket = UserTicket(dictionary: document.data()) {
                    return ticket //Return dictionary
                } else { //Error
                    fatalError("Unable to initialize type \(UserTicket.self) with dictionary \(document.data())")
                }
            }
            
            self.dbTickets = results //Assign array of results to TableView array
            self.tableView.reloadData() //Reload tableview with new results.
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    //MARK: - TableView Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //Number of sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbTickets.count //Number of rows
    }

    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let ticket: UserTicket //Define empty ticket object
        ticket = dbTickets[indexPath.row] //Retrieve ticket object from array of tickets
        
        //Assign values to cell
        cell.textLabel?.text = ticket.show //Main text label to display show name
        let suffix = showFuncs.suffixFromTimestamp(timestamp: ticket.date!) //Retrieve suffix for date
        let date = showFuncs.timestampDateConverter(timestamp: ticket.date!, format: "MMMM d") //Get date without year
        let year = showFuncs.timestampDateConverter(timestamp: ticket.date!, format: " YYYY") //Get year
        //Secondary text label to display date
        cell.detailTextLabel?.text = date + suffix + year //Add beginning of date, suffix, and year together
        return cell //Return custom cell with ticket values
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTicketDetailsView", sender: nil)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTicketDetailsView" //Validate the segue
        {
            //Instantiate destination class
            let destinationVC = segue.destination as! TicketDetailsViewController
            //Get index of cell selected from tableview
            let indexPath = self.tableView.indexPathForSelectedRow
            //Use index to get the Ticket object associated with the selected cell
            let ticket = dbTickets[indexPath!.row]
            //Pass object to next view
            destinationVC.ticket = ticket
        }
    }
}

