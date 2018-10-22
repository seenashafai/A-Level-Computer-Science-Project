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

class TicketPortalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var db: Firestore!
    var user = FirebaseUser()
    var dateSelected: String = ""
    var houseSelected: String = ""
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var show = [Show]()
    var ticket = [Ticket]()
    var houseInitialsArray = [String]()
    
    
    //MARK: - IB Links
    
    @IBOutlet weak var ticketNumberTextField: UITextField!
    @IBOutlet weak var ticketNumberStepper: UIStepper!
    
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var housePickerView: UIPickerView!
    
    @IBAction func ticketNumberStepperAction(_ sender: Any) {
        self.ticketNumberTextField.text = Int(ticketNumberStepper.value).description
    }
    
    //MARK: - Properties
    var dateArray = ["Please select a date...","Thursday 4th December", "Friday 5th December", "Saturday 6th December"]
    
    var ticketShowTitle: String = ""
    
    
    @IBAction func submitButtonPressed(_ sender: Any)
    {
        let numberOfTickets = Int(ticketNumberTextField.text!)
        let house = houseSelected
        let date = dateSelected
        print(house, "house")
        print(date, "date")
        let ticketAvailabilityRef = db.collection("shows").document(ticketShowTitle).collection("ticketing").document("statistics")
        print(ticket)
        ticketAvailabilityRef.updateData([
            
            "availableTickets": ticket[0].availableTickets - numberOfTickets!,
            "numberOfTicketHolders": ticket[0].numberOfTicketHolders + 1,
            "ticketHolders": FieldValue.arrayUnion([user.getCurrentUserEmail()])
            
        ]) { err in
            if err != nil {
                print("error", err?.localizedDescription)
            } else
            {
                print("success")
            }
        }
        
    }
    
    //MARK: - Firebase Query methods

 fileprivate func baseQuery() -> Query{
        return db.collection("shows").document(ticketShowTitle).collection("ticketing")
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
            }
        }
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
        if pickerView == housePickerView
        {
            return houseInitialsArray.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == datePickerView
        {
            return dateArray[row]
        }
        if pickerView == housePickerView
        {
            return houseInitialsArray[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePickerView
        {
            dateSelected = dateArray[row]
            print(dateSelected)
        }
        if pickerView == housePickerView
        {
            houseSelected = houseInitialsArray[row]
            print(houseSelected)
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
        
        let houseArrayRef = db.collection("properties").document("houses")
        houseArrayRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.houseInitialsArray = document["houseInitialsArray"] as? Array ?? [""]
                print(self.houseInitialsArray)
            }
            self.housePickerView.reloadAllComponents()
        }
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Ticket in
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
}

/*
 let houseArrayRef = db.collection("properties").document("houses")
 houseArrayRef.setData(["houseInitialsArray": ["Please select a house...","ABH", "AMM", "ASR", "AW", "BJH", "Coll", "DWG", "EJNR", "HWTA", "JCAJ", "JD", "JDM", "JDN", "JMG", "JMO\'B", "JRBS", "MGHM", "NA", "NCWS", "NPTL", "PAH", "PEPW", "PGW", "RDO-C", "SPH"]])
 */

