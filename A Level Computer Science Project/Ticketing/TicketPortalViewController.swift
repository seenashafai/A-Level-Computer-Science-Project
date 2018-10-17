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

    
    @IBOutlet weak var ticketNumberTextField: UITextField!
    @IBOutlet weak var ticketNumberStepper: UIStepper!
    
    @IBAction func ticketNumberStepperAction(_ sender: Any) {
        self.ticketNumberTextField.text = Int(ticketNumberStepper.value).description
    }
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var housePickerView: UIPickerView!
    
    var houseArray = ["Please select a house...", "Coll", "JCAJ", "DWG", "JMG", "NA", "HWTA", "ABH", "SPH", "AMM", "NPTL", "JDM", "MGHM", "JD", "PEPW", "JMO'B", "RDO-C", "JDN", "BJH", "ASR", "JRBS", "NCWS", "EJNR", "PAH", "AW", "PGW"]
    
    var dateArray = ["Please select a date...","Thursday 4th December", "Friday 5th December", "Saturday 6th December"]
    
    var ticketShowTitle: String = ""
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

        print(ticketShowTitle)
        ticketNumberStepper.maximumValue = 5
        navigationItem.title = "Booking for \(ticketShowTitle)"
        print(houseArray.count)

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
