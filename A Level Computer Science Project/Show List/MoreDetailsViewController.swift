//
//  MoreDetailsViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 15/12/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD
import DataCompression

class MoreDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK: - Properties
    var db: Firestore!
    var showDataDict: [String: Any]?
    var houseInitialsArray: [String]?
    var houseSelected: String?
    var edit: Bool?
    var show: Show?
    
    //Global variables
    var blockDict: [String: Any] = [:]
    var houseDict: [String: Any] = [:]

    //Connect UI to Class
    @IBOutlet weak var housePickerView: UIPickerView!
    @IBOutlet weak var directorTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    //Finish button pressed
    @IBAction func finishAction(_ sender: Any) {
        let name = showDataDict!["name"] as! String
        let director = directorTextField.text
        let description = descriptionTextView.text
        showDataDict?["director"] = director as Any
        showDataDict?["description"] = description as Any
        showDataDict?["house"] = houseSelected ?? ""
        let originalName = show?.name
        if edit == true
        {
            //Define alert and error message title and description
            let modificationAlert = UIAlertController(title: "Warning", message: "Any changes you make cannot be undone past this point. Would you like to continue? ", preferredStyle: .alert)
            modificationAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: //Add action to yes/no buttons
                {action in //Begin action methods...
                    let showRef = self.db.collection("shows").document(name)//Define database location of new show
                    showRef.setData(self.showDataDict!) { error in  //Define database location with new show dictionary
                        //Begin completion handler...
                        if error != nil { //If an error is present
                            print("error found", error?.localizedDescription as Any) //Print the error description
                        } else
                        {
                            print("success - no error given") //Trace statement to show that there was no error
                            let oldShowRef = self.db.collection("shows").document(originalName!) //Define old database location of show
                            oldShowRef.delete() //Delete the old show reference
                        }
                    }
                    self.navigationController?.popViewController(animated: true) //Navigate the user back to the show table
            }))
            modificationAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil)) //Add a 'no' button with no actions
            self.present(modificationAlert, animated: true) //Present the alert to the user along with the two action buttons
        }
        else
        {
            let showRef = db.collection("shows").document(name)
            showRef.setData(showDataDict!)
        }
    }
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == housePickerView
        {
            return houseInitialsArray?.count ?? 0
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == housePickerView
        {
            return houseInitialsArray?[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == housePickerView
        {
            houseSelected = houseInitialsArray?[row]
        }
    }
    
    func initialiseHousePickerForEditing()
    {
        for house in houseInitialsArray!
        {
            if show?.house == house
            {
                let houseIndex = houseInitialsArray?.firstIndex(of: house)
                housePickerView.selectRow(houseIndex!, inComponent: 0, animated: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

        //Set textfield placeholders if in editing state
        if edit == true
        {
            directorTextField.text = show?.director
            descriptionTextView.text = show?.description
        }
        //Define array of possible houses
        houseInitialsArray = ["Please select a house...","ABH", "AMM", "ASR", "AW", "BJH", "Coll", "DWG", "EJNR", "HWTA", "JCAJ", "JD", "JDM",
                              "JDN", "JMG", "JMO\'B", "JRBS", "MGHM", "NA", "NCWS", "NPTL", "PAH", "PEPW", "PGW", "RDO-C", "SPH"]
        self.housePickerView.reloadAllComponents() //Reload picker with new labels
        self.initialiseHousePickerForEditing()

        //Disable the picker unless a house play is being configured
        if showDataDict?["Category"] as! String != "House"
        {
            housePickerView.isUserInteractionEnabled = false
        }
        //Change the text colour of the picker to white
        housePickerView.setValue(UIColor.white, forKeyPath: "textColor")
    }
}
