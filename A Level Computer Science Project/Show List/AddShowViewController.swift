//
//  AddShowViewController.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 02/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase

class AddShowViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    

    //MARK: - Properties
    var db: Firestore!
    var dateArray = ["Please select a date...","Thursday 4th December", "Friday 5th December", "Saturday 6th December"]

    
    
    @IBAction func confirmAction(_ sender: Any) {
        var venue = "Caccia Studio"
        var availableTickets = 400
        var name = "TheCoolShow"
        var category = "House"
        var date = "19th October 2019"
        let showRef = db.collection("shows").document(name)
        showRef.setData([
            "Category": category,
            "Date": date,
            "availableTickets": availableTickets,
            "name": name,
            "venue": venue
        ])
    }
    
    
    @IBOutlet var showNameTextField: UITextField!
    @IBOutlet var categorySegmentedControl: UISegmentedControl!
    @IBOutlet var venueSegmentedControl: UISegmentedControl!
    @IBOutlet var datePickerView: UIPickerView!
    @IBOutlet var housePickerView: UIPickerView!
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        let houseArrayRef = db.collection("properties").document("houses")
        houseArrayRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.houseInitialsArray = document["houseInitialsArray"] as? Array ?? [""]
                print(self.houseInitialsArray)
            }
            self.housePickerView.reloadAllComponents()
        }

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
