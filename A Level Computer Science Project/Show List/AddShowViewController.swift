//
//  AddShowViewController.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 02/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase

class AddShowViewController: UIViewController {

    //MARK: - Properties
    var db: Firestore!
    
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

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
