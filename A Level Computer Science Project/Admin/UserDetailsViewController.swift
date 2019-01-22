//
//  UserDetailsViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 22/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class UserDetailsViewController: UIViewController {

    var user: User?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var ticketLabel: UILabel!
    @IBOutlet weak var attendanceLabel: UILabel!
    @IBOutlet weak var showsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fullUserName = String((user?.firstName)! + (user?.lastName)!)
        nameLabel.text = fullUserName
        emailLabel.text = user?.email
        blockLabel.text = user?.block
        houseLabel.text = user?.house
        ticketLabel.text = String((user?.ticketsBooked)!)
        attendanceLabel.text = user?.showAttendance.description
        showsLabel.text = user?.showsBookedArray.description
    }
}
