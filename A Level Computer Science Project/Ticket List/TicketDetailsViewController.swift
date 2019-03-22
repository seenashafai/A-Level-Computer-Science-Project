//  TicketDetailsViewController.swift
//  Copyright © 2019 Seena Shafai. All rights reserved.

import UIKit
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
        downloadTicket()
    }
    
    @IBOutlet weak var reviewOutlet: UIButton!
    var user = FirebaseUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        showTextLabel.text = ticket?.show
        
        
        let suffix = showFuncs.suffixFromTimestamp(timestamp: ticket!.date) //Retrieve suffix for date
        let date = showFuncs.timestampDateConverter(timestamp: ticket!.date, format: "MMMM d") //Get date without year
        let year = showFuncs.timestampDateConverter(timestamp: ticket!.date, format: " YYYY") //Get year
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReviewView"
        {
            let destinationVC = segue.destination as! ReviewViewController
            destinationVC.ticket = ticket
        }
    }
    
}
