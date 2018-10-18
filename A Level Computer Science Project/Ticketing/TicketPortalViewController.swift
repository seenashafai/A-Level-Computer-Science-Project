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

    
    
    //MARK: - IB Links
    
    @IBOutlet weak var ticketNumberTextField: UITextField!
    @IBOutlet weak var ticketNumberStepper: UIStepper!
    
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var housePickerView: UIPickerView!
    
    @IBAction func ticketNumberStepperAction(_ sender: Any) {
        self.ticketNumberTextField.text = Int(ticketNumberStepper.value).description
    }
    
    @IBAction func submitButtonPressed(_ sender: Any)
    {
        var numberOfTickets = Int(ticketNumberTextField.text!)
        var house = houseSelected
        var date = dateSelected
        print(house, "house")
        print(date, "date")
        let dbRef = db.collection("users").document(userEmail()).collection("ticket").document(ticketShowTitle)
        dbRef.setData([
            "date": date,
            "numberOfTickets": numberOfTickets,
            "house": house
            
        ]) { err in
            if let err = err {
                print("error")
            } else
            {
                print("success")
            }
        }
    }
    

    
    //MARK: - Properties
    
    var houseArray = ["Coll", "JCAJ", "DWG", "JMG", "NA", "HWTA", "ABH", "SPH", "AMM", "NPTL", "JDM", "MGHM", "JD", "PEPW", "JMO'B", "RDO-C", "JDN", "BJH", "ASR", "JRBS", "NCWS", "EJNR", "PAH", "AW", "PGW"]
    
    var dateArray = ["Please select a date...","Thursday 4th December", "Friday 5th December", "Saturday 6th December"]
    
    var ticketShowTitle: String = ""
    
    
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
            return houseArray.count
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
            return houseArray[row]
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
            houseSelected = houseArray[row]
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
        
        ticketNumberTextField.text = String(1)
        ticketNumberStepper.maximumValue = 5
        ticketNumberStepper.minimumValue = 1
        houseArray = houseArray.sorted(by: {$0 < $1})
        houseArray.insert("Please select a house...", at: 0)
        navigationItem.title = "Booking for \(ticketShowTitle)"

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
