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
    var houseInitialsArray = ["ABH", "AMM", "ASR", "AW", "BJH", "Coll", "DWG", "EJNR", "HWTA", "JCAJ", "JMG", "JD", "JDM", "JMO'B", "JRBS", "MGHM", "NA", "NCWS", "NTPL", "PAH", "PEPW", "PGW", "RDO-C"]
    var houseSelected: String?
    

    //MARK: - Interface Objects
    @IBOutlet weak var housePickerView: UIPickerView!
    @IBOutlet weak var directorTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK: - Interface actions
    @IBAction func finishAction(_ sender: Any)
    {
        //Add new data to dictionary
        showDataDict!["director"] = directorTextField.text
        showDataDict!["description"] = descriptionTextView.text
        showDataDict!["house"] = houseSelected ?? ""
        
        //Push to database
        let name = showDataDict!["name"] as! String//Get show name
        let showRef = db.collection("shows").document(name) //Create show reference
        showRef.setData(showDataDict!) //Add data to show node in database
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
    
    //MARK: - UIPickerViewDelegate + Datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1 //Number of components/sections
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return houseInitialsArray.count //Number of rows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return houseInitialsArray[row] //Title for each row
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        houseSelected = houseInitialsArray[row] //Get selected row
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore() //Initialise database
        //Check if category is not House
        if showDataDict?["Category"] as! String != "House"
        {
            //Disable user interaction if not a house play
            housePickerView.isUserInteractionEnabled = false
        }
    }

}

