//
//  TicketDetailsViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 10/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PassKit
import Alamofire

class TicketDetailsViewController: UIViewController, PKAddPassesViewControllerDelegate {

    //MARK: - Properties
    var ticket: UserTicket?
    
    let APIEndpoint = "https://ftpkdist.serveo.net"
    
    //MARK: - IBOutlets
    @IBOutlet weak var showTextLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var ticketsTextLabel: UILabel!
    @IBOutlet weak var seatsTextLabel: UILabel!
    @IBOutlet weak var attendanceTextLabel: UILabel!
    
    
    var showName: String?
    var showFuncs = showFunctions()
    var db: Firestore!
    var isUserSignedIn: Bool = false
    var editable: Bool = false
    let alerts = Alerts()
    var docExists: Bool?
    
    @IBOutlet weak var addPassButton: UIButton!
    @IBAction func addPassAction(_ sender: Any) {
        print("pressed")
        downloadTicket()
    }
    
    @IBAction func reviewAction(_ sender: Any) {
    }
    @IBOutlet weak var reviewOutlet: UIButton!
    var user = FirebaseUser()

    
    @IBAction func deleteAction(_ sender: Any) {
        
        let deleteAlert = UIAlertController(title: "Warning", message: "If you delete this ticket you may not be granted access to the show. This action cannot be undone. Would you like to continue", preferredStyle: .alert) //Define alert and error message title and description
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: //Add action to yes/no button
            {   action in //Begin action methods...
                
                let email = self.user.getCurrentUserEmail()
                let ticketRef = self.db.collection("users").document(email).collection("tickets").document((self.ticket?.show)!)
                ticketRef.delete()
                self.navigationController?.popViewController(animated: true)
                
            }))
        deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil)) //Add a 'no' button with no actions
        self.present(deleteAlert, animated: true) //Present the alert to the user along with the two action buttons
    }
    
    func doesReviewExist()
    {
        let dateIndex = ticket!.dateIndex
        let strDateIndex = String(dateIndex)
        let ratingsRef = db.collection("shows").document((ticket?.show)!).collection(strDateIndex).document("reviews").collection(user.getCurrentUserEmail()).document("review")
        ratingsRef.getDocument { (document, error ) in
            if let document = document {
                if document.exists {
                    self.docExists = true
                    print("docExists")
                } else {
                    self.docExists = false
                    print("first time review")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showTextLabel.text = ticket?.show
        
        
        let suffix = showFuncs.suffixFromTimestamp(timestamp: ticket!.date!) //Retrieve suffix for date
        let date = showFuncs.timestampDateConverter(timestamp: ticket!.date!, format: "MMMM d") //Get date without year
        let year = showFuncs.timestampDateConverter(timestamp: ticket!.date!, format: " YYYY") //Get year
        //Secondary text label to display date
        dateTextLabel.text = date + suffix + year
        ticketsTextLabel.text = ticket?.tickets
        seatsTextLabel.text = ticket?.seats
        if ticket?.attendance == false
        {
            attendanceTextLabel.text = "False"
            reviewOutlet.isUserInteractionEnabled = false //Disable user interaction

        } else {
            attendanceTextLabel.text = "True"
        }
        // Do any additional setup after loading the view.
    }
    
    func downloadTicket()
    {
        //Define URL for HTTP GET request with UID + pass suffix
        let ticketEndpoint = APIEndpoint+"/users/\((ticket!.ticketID))/pass.pkpass"
        print(ticket!.ticketID, "tId")
        
        //Send request, with 'GET' method, default encoding and no form fields...
        
        Alamofire.request(ticketEndpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in //Open closure to handle errors and results
                print(response.request?.description)
                //Error Handling & Converting JSON data to pass
                
                let pass = try? PKPass(data: response.data!)
                if let ticket = pass{
                    //Results handling...
                    let pkvc = PKAddPassesViewController(pass: ticket) //Create temporary view to present downloaded pass
                    pkvc!.delegate = self //Set delegate to current class
                    //Present temporary view to user
                    self.present(pkvc!, animated: true, completion: {() -> Void in
                        print("presented pkvc") //Trace output, executes once the temporary view has completed its animation
                    })
                } else {
                    print("server issues")
                }
        }
    }

    func presentExistingReviewAlert()
    {
        let existingReviewAlert = UIAlertController(title: "Error", message: "You have already written a review for this show. You may only write one review per show, per night.", preferredStyle: .alert) //Define alert and error message title and description
        existingReviewAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))//Add action to yes/no button
        self.present(existingReviewAlert, animated: true) //Present the alert to the user along with the two action buttons
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toReviewView"
        {
            if docExists == true
            {
                presentExistingReviewAlert()
                return true
                
            }
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReviewView"
        {
            let destinationVC = segue.destination as! ReviewViewController
            destinationVC.ticket = ticket
        }
    }

}
