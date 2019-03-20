//
//  TicketConfirmationViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 26/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD
import MaterialComponents.MDCSnackbarMessage
import LocalAuthentication
import Alamofire
import PassKit

class TicketConfirmationViewController: UIViewController, PKAddPassesViewControllerDelegate {

    //API Variables:
    let APIEndpoint = "http://ftpkdist.serveo.net/users"
    var UID: Int?

    //Class instances
    var showFuncs = showFunctions()
    var dateValue: Date?
    
    
    var db: Firestore!
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var transaction = [Transaction]()
    var user = FirebaseUser()
    let auth = Validation()
    let barcode = Barcode()
    let alerts = Alerts()
  
    var dateIndex: Int?
    var modifiedDate: Date?
    var currentTransaction: Int?

    //MARK: - User Properties
    var firstName: String?
    var lastName: String?
    var house: String?
    var block: String?
    var venue: String?
    var ticketsBooked: Int?
    var showsBookedArray: [String]?
    var showAttendanceDict: [String: Any] = [:]
    
    
    var show: String?
    var date: String?
    var tickets: String?
    var seats: String?
    var email: String?
    
    
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ticketsLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var houseLabel: UILabel!
    
    @IBAction func finishAction(_ sender: Any) {
       // guard auth.authenticateUser(reason: "Use your fingerprint to validate your booking") == true else {print("gtfo"); return}
            //HUD.show(HUDContentType.systemActivity)

        
            loadUser() //Load user details
            loadShowDetails() //Load venue & date details
        
        

        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getUID() //Load current UID

        //Assign labels as variables passed from previous view
        showLabel.text = show
        dateLabel.text = date
        ticketsLabel.text = tickets
        seatsLabel.text = seats
        emailLabel.text = email

        // Do any additional setup after loading the view.
    }
    
    func loadUser() //Load user's details from Firestore database
    {
        //Define location of user details (query)
        print(email!, "email")
        
        let userReference = db.collection("users").document((Auth.auth().currentUser?.email)!)
        //Begin query- retrieve document snapshot from database
        userReference.getDocument {(documentSnapshot, error) in
            if let error = error //Validate that there is no error
            {
                print(error.localizedDescription) //Output error
                return //Exit function
            }
            //Handle results:
            if let document = documentSnapshot { //Valiate that document snapshot exists
                let dictionary = document.data()! //Define dictionary from API returned document
                self.firstName = dictionary["firstName"] as? String //Extract first name from dictionary
                self.lastName = dictionary["lastName"] as? String //Extract last name from dictionary
            }
        }
    }
    
    func loadShowDetails() //Load venue details from Firestore database
    {
        //Define location of show details (query)
        let showRef = db.collection("shows").document(show!)
        //Begin query - retrieve document snapshot from database
        showRef.getDocument {(documentSnapshot, error) in
            if let error = error //Validate that there is no error
            {
                //Handle error if returned
                print(error.localizedDescription, "venueError")
                return //Exit function
            }
            //Validate that results have been returned
            if let document = documentSnapshot {
                //Handle results if returned
                let dictionary = document.data()!
                
                //Pull Venue
                self.venue = dictionary["venue"] as? String //Load assign venue to local variable
                
                //Pull Date
                let timestamp = dictionary["Date"] as? Timestamp //Retrieve timestamp
                self.dateValue = timestamp?.dateValue() //Convert timestamp to date
                //Increment date accordingly
                self.modifiedDate = self.showFuncs.DateFromStart(date: self.dateValue!, index: self.dateIndex!)
                self.pushToDB()
                
            }
        }
    }

    
    func getUID() //Get UID of next user
    {
        //Define database location for query
        let transactionRef = db.collection("properties").document("transactions")
        //Query database location
        transactionRef.getDocument {(documentSnapshot, error) in
            //Handle error
            if let error = error
            {
                //Error returned
                print(error.localizedDescription) //Output error message
                return //Exit function
            }
            //Validate response
            if let document = documentSnapshot {
                //Assign response to variable
                self.UID = document.data()!["runningTotal"] as? Int
            }
        }
    }

    func updateUID() //Update UID for next user
    {
        //Define query location
        let transactionRef = db.collection("properties").document("transactions")
        transactionRef.updateData([ //Update data at query location
            "runningTotal": self.UID! + 1 //Increment UID by 1
            ])
    }
    
    func pushToDB()
    {
        //Define location for data to be uploaded
        let userTicketRef = db.collection("users").document(email!).collection("tickets").document(show!)
        //Set data...
        //Set data at the defined location
        userTicketRef.setData([
            "ticketID": UID!,
            "show": show!,
            "seats": seats!,
            "tickets": tickets!,
            "date": modifiedDate!, //Old value: date
            "attendance": false,
            "dateIndex": dateIndex!
            //Handle errors...
            ])
        { err in //Define error variable
            //Validate error
            if err != nil { //If the error is not empty
                print(err?.localizedDescription as Any) //Output the error
            } else //No error returned
            {
                //Wait .2 seconds to allow the database to finish loading the user and venue information
                self.delayWithSeconds(0.2) {
                    self.initialiseForm() //Send the form details to the Ruby back-end
                    self.downloadTicket()
                    self.updateUID()
                }
                
                //Transition user back to the home page of the play
                self.delayWithSeconds(3) {
                    let  vc =  self.navigationController?.viewControllers[2]
                    self.navigationController?.popToViewController(vc!, animated: true)
                }
            }
        }
    }
    
    func initialiseForm()
    {
        let formName = "\(String(describing: self.firstName!)) \(String(describing:self.lastName!))"
        let formEmail = email!
        let formSeatRef = self.seatsLabel.text!
        let formShow = self.showLabel.text!
        let formVenue = self.venue ?? "Empty Space"
        
        let suffix = showFuncs.suffixFromDate(date: dateValue!)
        let formDate = showFuncs.formatDate(date: modifiedDate!, format: "MMMM d")
        let formYear = showFuncs.formatDate(date: modifiedDate!, format: " YYYY")
        
        let combinedDate = formDate + suffix + formYear
        
        let formFields: [String: String] = ["user[name]":formName, "user[email]":formEmail, "user[seatRef]":formSeatRef, "user[show]": formShow, "user[venue]": formVenue, "user[date]": combinedDate]
        
        //Define request method as POST
        let POST: HTTPMethod = HTTPMethod.post
        //API Request function, taking the endpoint and method as parameters
        Alamofire.request(self.APIEndpoint, method: POST, parameters: formFields, encoding: URLEncoding()).responseString { response  in //Closure (No action needed)
            print(response.request?.mainDocumentURL?.description)
        }
    }
    
    func downloadTicket()
    {
        //Define URL for HTTP GET request with UID + pass suffix
        let ticketEndpoint = APIEndpoint+"/\(UID!)/pass.pkpass"
        
        //Send request, with 'GET' method, default encoding and no form fields
        Alamofire.request(ticketEndpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in //Open closure to handle errors and results
                print(response.request?.debugDescription)
                //Error Handling & Converting JSON data to pass
                let pass = try? PKPass(data: response.data!)
                //Results handling...
                let pkvc = PKAddPassesViewController(pass: pass!) //Create temporary view to present downloaded pass
                pkvc!.delegate = self //Set delegate to current class
                //Present temporary view to user
                self.present(pkvc!, animated: true, completion: {() -> Void in
                    print("presented pkvc") //Trace output, executes once the temporary view has completed its animation
                })
            }
        }
    
    
    //Executes when user selects the add or cancel button
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController)
    {
        //Dismiss view
        controller.dismiss(animated: true, completion: nil)
    }

    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

