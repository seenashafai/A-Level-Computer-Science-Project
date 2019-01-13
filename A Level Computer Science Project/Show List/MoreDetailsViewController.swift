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

    var db: Firestore!
    var showDataDict: [String: Any]?
    var houseInitialsArray: [String]?
    var houseSelected: String?
    var edit: Bool?
    var show: Show?


    @IBOutlet weak var housePickerView: UIPickerView!
    @IBOutlet weak var directorTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    
    @IBAction func finishAction(_ sender: Any) {
        compareAlgorithms()
        let name = showDataDict!["name"] as! String
        print(name, "showNameagain")
        let director = directorTextField.text
        let description = descriptionTextView.text
        showDataDict?["director"] = director as Any
        showDataDict?["description"] = description as Any
        showDataDict?["house"] = houseSelected ?? ""
        print(showDataDict?.description, "showDataDesc")
        let originalName = show?.name
        print(edit, "isEdit")
        if edit == true
        {
            let modificationAlert = UIAlertController(title: "Warning", message: "Any changes you make cannot be undone past this point. Would you like to continue? ", preferredStyle: .alert) //Define alert and error message title and description
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
            let seatsArray = self.arrayGen()
            for i in 1..<4
            {
                let ticketAvailabilityRef = self.db.collection("shows").document(name).collection(String(i)).document("statistics")
                print(seatsArray, "seats")
                ticketAvailabilityRef.setData([
                    "availableSeats": seatsArray, // generate new seating chart
                    "availableTickets": 100,
                    "numberOfTicketHolders": 0,
                    "ticketHolders": FieldValue.arrayUnion([])
                ])  { err in
                    if err != nil {
                        print("error", err?.localizedDescription)
                    } else
                    {
                        print("success")
                    }
                }
            }
            navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
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
    
    func compressDescription() -> Any
    {
        let raw: Data! = String(descriptionTextView.text).data(using: .utf8) //Define raw input string
        let compressedData = raw.compress(withAlgorithm: .zlib) //Compress using zlib algorithm

        return compressedData as Any
        
    }
    
    func compareAlgorithms()
    {
        let raw: Data! = String("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.").data(using: .utf8)
        
        print("raw   =>   \(raw.count) bytes")
        
        for algorithm: Data.CompressionAlgorithm in [.zlib, .lzfse, .lz4, .lzma] //Set up compression loop
        {   //Loop iterates through each compression algorithm and applies it to the string
            let compressedStr: Data! = raw.compress(withAlgorithm: algorithm) //Compress string
            //Ratio calculated by comparing the number of characters in the original string and the compressed string
            let ratio = Double(raw.count) / Double(compressedStr.count) //Calculate compression ratio
            print("\(algorithm)   =>   \(compressedStr.count) bytes, ratio: \(ratio)") //Output calculation
            
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
            print(houseSelected)
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
        if edit == true
        {
            directorTextField.text = show?.director
            descriptionTextView.text = show?.description
        }
        print(showDataDict, "showDataDict")
        
        db = Firestore.firestore()

        let houseArrayRef = db.collection("properties").document("houses")
        houseArrayRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.houseInitialsArray = document["houseInitialsArray"] as? Array ?? [""]
                print(self.houseInitialsArray)
            }
            self.housePickerView.reloadAllComponents()
            self.initialiseHousePickerForEditing()

        }
        
        if showDataDict?["Category"] as! String != "House"
        {
            housePickerView.isUserInteractionEnabled = false
        }
        print(showDataDict, "transferred")
        housePickerView.setValue(UIColor.white, forKeyPath: "textColor")


        // Do any additional setup after loading the view.
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
/*
    func firebase()
    {
     
    }
 */
}
