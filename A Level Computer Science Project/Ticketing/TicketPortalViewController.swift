//
//  TicketPortalViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 15/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TicketPortalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Properties
    //Database Config
    var db: Firestore!
    var listener: ListenerRegistration!

    //Class Instances
    var user = FirebaseUser()
    var showFuncs = showFunctions()
    var show: Show?
    var ticket: Ticket?
    
    //Global Variables
    var dateSelected: String = ""
    var dateIndex: Int = 0
    var currentUser: [String: Any] = [:]
    
    
    //MARK: - IB Links
    @IBOutlet weak var ticketNumberTextField: UITextField!
    @IBOutlet weak var ticketNumberStepper: UIStepper!
    @IBOutlet var beginningDateLabel: UILabel!
    
    @IBOutlet weak var datePickerView: UIPickerView!
    
    //Stepper clicked
    @IBAction func ticketNumberStepperAction(_ sender: Any) {
        self.ticketNumberTextField.text = Int(ticketNumberStepper.value).description
    }
    
    //MARK: - Properties
    var dateArray = ["Please select a date...","Thursday", "Friday", "Saturday"]
    var ticketShowTitle: String = ""
    
    
    @IBAction func submitButtonPressed(_ sender: Any)
    {
        let numberOfTickets = Int(ticketNumberTextField.text!) //Number of tickets requested
        let updatedTicketNumber = (ticket?.availableTickets)! - numberOfTickets! //Number of tickets remaining
        let userEmail = Auth.auth().currentUser!.email
        var ticketHoldersArray = ticket?.ticketHolders
        //Check if either validation returned false
        if isTicketRequestValid2(requestedTickets: numberOfTickets!, availableTickets: (ticket?.availableTickets)!) == false || isUserValid(user: userEmail!, ticketHolders: ticketHoldersArray!) == false
        {
            print("Validation failed")
            return //Exit function
        }
        //Database Methods
        ticketHoldersArray?.append(userEmail!) //Add user's email to ticket holders array
        let ticketAvailabilityRef = db.collection("shows").document(ticketShowTitle).collection(String(dateIndex)).document("statistics") //Define database location
        ticketAvailabilityRef.updateData([ //Update data in database
            "availableTickets": updatedTicketNumber, //Update with new available ticket number
            "ticketHolders": ticketHoldersArray! //Update with new ticket holders array
            //Error Handling
        ])  { err in //CLOSURE: validation of error variable
            if err != nil { //If the error returned is not empty
                print(err?.localizedDescription) //Output error message
            } else //No error returned
            {
                print("success") //Console output for testing
                self.performSegue(withIdentifier: "toSeatSelection", sender: nil) //Transition to seat selection
            }
        }
        
    }
    
    func isUserValid(user: String, ticketHolders: [String]) -> Bool
    {
        for i in 0..<(ticketHolders.count) //Loop through the ticket holders array
        {
            if user == ticketHolders[i] //Checks for a match between the user and ticketholders
            {
                //Match found
                print("User is already a ticket holder")
                return false
            }
        }
        //No match found
        print("User validation succeeded")
        //Return true if user does not return a match (i.e. not already a ticket holder)
        return true
        
    }
    
    func isTicketRequestValid2(requestedTickets: Int, availableTickets: Int) -> Bool
    {
        
        if requestedTickets > availableTickets { //Check that the user hasn't selected more tickets than are available
            //Output number of tickets requested, and number available for debugging
            print("User requested \(requestedTickets), but only \(availableTickets) remain")
            return false
        }
        print("ticket validation succeeded")
        return true //Default case
        
    }
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 //Number of sections in picker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateArray.count //Number of rows in picker
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dateArray[row] //Title for each row of picker
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePickerView {
            dateSelected = dateArray[row] //Get name of row selected (date string)
            dateIndex = pickerView.selectedRow(inComponent: 0) //Get index of row selected (date index)
        }
    }
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        let timestamp: Timestamp = (show?.date)!
        let suffix = showFuncs.suffixFromTimestamp(timestamp: timestamp)
        let format = "d, MMMM"
        beginningDateLabel.text = "Beginning on:" + showFuncs.timestampDateConverter(timestamp: timestamp, format: format) + suffix
        
        let userEmail = Auth.auth().currentUser?.email
        let userRef = db.collection("users").document(userEmail!)
        userRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.currentUser = (document.data() ?? nil)!
                
            }
        }
        //Set default, maximum, minimum values of text box
        ticketNumberTextField.text = String(1)
        ticketNumberStepper.maximumValue = 5
        ticketNumberStepper.minimumValue = 1
        navigationItem.title = "Booking for \(ticketShowTitle)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        //Remove database listener when view is dismissed
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Assign listener to get show details
        let query =  db.collection("shows").document(ticketShowTitle).collection("1")
        self.listener = query.addSnapshotListener { (documents, error) in
            //Handle any errors
            guard let snapshot = documents else { //If error returned
                print("Error fetching documents results: \(error!)") //Print error message
                return
            }
            //Handle result of listener execution
            let results = snapshot.documents.map { (document) -> Ticket in //Map QuerySnapshot to Ticket class
                if let ticket = Ticket(dictionary: document.data()) { //Validate ticket matches Ticket class
                    return ticket
                } else { //Return fatal error when the two objects are incompatible
                    fatalError("Unable to initialize type \(Ticket.self) with dictionary \(document.data())")
                }
            }
            self.ticket = results[0] //Assign ticket to variable
            print(self.ticket as Any) //Output ticket for tracing
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSeatSelection"
        {
            //Pass variables onto next class
            let destinationVC = segue.destination as! SecondarySeatSelectionViewController
            destinationVC.allocatedSeats = Int(ticketNumberTextField.text!)
            destinationVC.showName = ticketShowTitle
            destinationVC.date = dateSelected
            destinationVC.dateIndex = dateIndex
            destinationVC.currentUser = currentUser
            
        }
    }
    
}

