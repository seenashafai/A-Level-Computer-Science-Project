//
//  TicketPortalViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 15/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class TicketPortalViewController: UIViewController {

    @IBOutlet weak var showNameTextLabel: UILabel!
    
    @IBOutlet weak var ticketNumberTextField: UITextField!
    @IBOutlet weak var ticketNumberStepper: UIStepper!
    
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var housePickerView: UIPickerView!
    
    var houseArray = ["Coll", "JCAJ", "DWG", "JMG", "NA", "HWTA", "ABH", "SPH", "AMM", "NPTL", "JDM", "MGHM", "JD", "PEPW", "JMO'B", "RDO-C", "JDN", "BJH", "ASR", "JRBS", "NCWS", "EJNR", "PAH", "AW", "PGW"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
