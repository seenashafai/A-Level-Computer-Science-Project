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


    @IBOutlet weak var housePickerView: UIPickerView!
    @IBOutlet weak var directorTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    
    @IBAction func finishAction(_ sender: Any) {
        compareAlgorithms()
        let name = showDataDict!["name"] as! String
        let director = directorTextField.text
        let description = descriptionTextView.text
        showDataDict?["director"] = director as Any
        showDataDict?["description"] = description as Any
        showDataDict?["house"] = houseSelected ?? ""
        print(showDataDict)
        let showRef = db.collection("shows").document(name)
        showRef.setData(showDataDict!)
        navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
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
        
        if showDataDict?["Category"] as! String != "House"
        {
            housePickerView.isUserInteractionEnabled = false
        }
        print(showDataDict, "transferred")
        housePickerView.setValue(UIColor.white, forKeyPath: "textColor")


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
/*
    func firebase()
    {
     
    }
 */
}
