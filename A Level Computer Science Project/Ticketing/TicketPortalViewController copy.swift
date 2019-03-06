//
//  TicketPortalViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 15/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD

class TicketPortalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var db: Firestore!
    var user = FirebaseUser()
    var dateSelected: String = ""
    var dateIndex: Int = 0
    var listener: ListenerRegistration!
    var show = [Show]()
    var ticket: Ticket?
    var currentUser: [String: Any] = [:]
    
    
    //MARK: - IB Links
    
    @IBOutlet weak var ticketNumberTextField: UITextField!
    @IBOutlet weak var ticketNumberStepper: UIStepper!
    
    @IBOutlet weak var datePickerView: UIPickerView!
    
    @IBAction func ticketNumberStepperAction(_ sender: Any) {
        self.ticketNumberTextField.text = Int(ticketNumberStepper.value).description
    }
    
    //MARK: - Properties
    var dateArray = ["Please select a date...","Thursday", "Friday", "Saturday"]
    
    var ticketShowTitle: String = ""
    
    
    @IBAction func submitButtonPressed(_ sender: Any)
    {
        arrayGen()
        let numberOfTickets = Int(ticketNumberTextField.text!) //Number of tickets requested
        print(numberOfTickets!, "requested Tickets") //Output number of tickets requested
        let updatedTicketNumber = (ticket?.availableTickets)! - numberOfTickets! //Number of tickets remaining
        let userEmail = Auth.auth().currentUser!.email
        var ticketHoldersArray = ticket?.ticketHolders
        print(updatedTicketNumber, "remaining Tickets") //Output remaining ticket number
        //Check if either validation returned false
        if isTicketRequestValid2(requestedTickets: numberOfTickets!, availableTickets: (ticket?.availableTickets)!) == false || isUserValid(user: userEmail!, ticketHolders: ticketHoldersArray!) == false
        {
            print("Validation failed")
            return //Exit function
        }
        //Else...
        ticketHoldersArray?.append(userEmail!) //Add user's email to ticket holders array
        let ticketAvailabilityRef = db.collection("shows").document(ticketShowTitle).collection(String(dateIndex)).document("statistics")
        ticketAvailabilityRef.updateData([
            "availableTickets": updatedTicketNumber,
            "ticketHolders": ticketHoldersArray
        ])  { err in
            if err != nil {
                print("error", err?.localizedDescription)
            } else
            {
                print("success")
                self.performSegue(withIdentifier: "toSeatSelection", sender: nil)
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
    
    //MARK: - Firebase Query methods

 fileprivate func baseQuery() -> Query{
        return db.collection("shows").document(ticketShowTitle).collection("1")
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
            }
        }
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
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateArray.count

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dateArray[row]

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePickerView {
            dateSelected = dateArray[row]
            dateIndex = pickerView.selectedRow(inComponent: 0)
        }
    }
    
    
    
    //MARK: - Private Instance Methods
    func userEmail() -> String
    {
        return user.getCurrentUserEmail()
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.query = baseQuery()

        let userEmail = Auth.auth().currentUser?.email
        let userRef = db.collection("users").document(userEmail!)
        userRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.currentUser = (document.data() ?? nil)!
                print(self.currentUser["house"], "housetime")
                
            }
        }
        
        ticketNumberTextField.text = String(1)
        ticketNumberStepper.maximumValue = 5
        ticketNumberStepper.minimumValue = 1
        navigationItem.title = "Booking for \(ticketShowTitle)"

        // Do any additional setup after loading the view.
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
            
            let results = snapshot.documents.map { (document) -> Ticket in
                print(document.data(), "docData")
                print(document, "doc")
                if let ticket = Ticket(dictionary: document.data()) {
                    return ticket
                } else {
                    fatalError("Unable to initialize type \(Ticket.self) with dictionary \(document.data())")
                }
            }
            
            self.ticket = results[0]
            print(self.ticket as Any)
         }
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSeatSelection"
        {
            let destinationVC = segue.destination as! SecondarySeatSelectionViewController
            destinationVC.allocatedSeats = Int(ticketNumberTextField.text!)
            destinationVC.showName = ticketShowTitle
            print(dateSelected, "ds1")
            destinationVC.date = dateSelected
            destinationVC.dateIndex = dateIndex
            destinationVC.currentUser = currentUser
            
        }
    }
    
}

