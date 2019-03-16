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
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var show = [Show]()
    var ticket = [Ticket]()
    
    
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
        let numberOfTickets = Int(ticketNumberTextField.text!)
        let date = dateSelected
        print(date, "date")
        let seatsArray = arrayGen()
        let ticketAvailabilityRef = db.collection("shows").document(ticketShowTitle).collection(String(dateIndex)).document("statistics")
        print(ticket)
        print(seatsArray, "seats")
        print(user.getCurrentUserEmail(), "currentUserEmail")
        print("availableTickets", ticket[0].availableTickets)
        ticketAvailabilityRef.updateData([
            "availableTickets": ticket[0].availableTickets - numberOfTickets!,
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
    
    //MARK: - Firebase Query methods

 fileprivate func baseQuery() -> Query{
        return db.collection("shows").document(ticketShowTitle).collection("1").whereField("availableTickets", isGreaterThanOrEqualTo: 0)
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
        if pickerView == datePickerView
        {
            return dateArray.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == datePickerView
        {
            return dateArray[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePickerView
        {
            dateSelected = dateArray[row]
            dateIndex = pickerView.selectedRow(inComponent: 0)
            print(dateIndex, "index")
            print(dateSelected)
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
            
            self.ticket = results
            self.documents = snapshot.documents
            print(self.ticket)
         }
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSeatSelection"
        {
            let destinationVC = segue.destination as! SecondarySeatSelectionViewController
            destinationVC.allocatedSeats = Int(ticketNumberTextField.text!)
            destinationVC.showName = ticketShowTitle
            destinationVC.date = dateSelected
            destinationVC.dateIndex = dateIndex
            
        }
    }
    
}


/*
 let houseArrayRef = db.collection("properties").document("houses")
 houseArrayRef.setData(["houseInitialsArray": ["Please select a house...","ABH", "AMM", "ASR", "AW", "BJH", "Coll", "DWG", "EJNR", "HWTA", "JCAJ", "JD", "JDM", "JDN", "JMG", "JMO\'B", "JRBS", "MGHM", "NA", "NCWS", "NPTL", "PAH", "PEPW", "PGW", "RDO-C", "SPH"]])
 */

