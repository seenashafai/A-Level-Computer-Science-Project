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

class MoreDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var db: Firestore!
    var showDataDict: [String: Any]?
    var houseInitialsArray: [String]?
    var houseSelected: String?


    @IBOutlet weak var housePickerView: UIPickerView!
    @IBOutlet weak var directorTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    
    @IBAction func finishAction(_ sender: Any) {
        let name = showDataDict!["name"] as! String
        let director = directorTextField.text
        let description = descriptionTextView.text
        showDataDict?["director"] = director as Any
        showDataDict?["description"] = description as Any
        showDataDict?["house"] = houseSelected ?? ""
        print(showDataDict)
        let showRef = db.collection("shows").document(name)
        showRef.setData(showDataDict!)
        
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
