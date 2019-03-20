//  TicketConfirmationViewController.swift
//  Copyright © 2018 Seena Shafai. All rights reserved.

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Alamofire
import PassKit

class TicketConfirmationViewController: UIViewController, PKAddPassesViewControllerDelegate {
    
    //PassKit API Variables:
    let APIEndpoint = "http://ftpkdist.serveo.net/users"
    var UID: Int?
    
    //Database Config
    var db: Firestore!
    var listener: ListenerRegistration!
    
    //Class Instances
    var user = FirebaseUser()
    let auth = Validation()
    
    //MARK: - User Properties
    var firstName: String?
    var lastName: String?
    var house: String?
    var block: String?
    var venue: String?
    
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

    @IBAction func finishAction(_ sender: Any) {
        //Initiate bio auth
        guard auth.authenticateUser(reason: "Use your fingerprint to validate your booking") == true else
        {
            //If failed:
            print("Bio Auth Failed");
            return
        }
        
       
        
        //Define location for data to be uploaded
        let userTicketRef = db.collection("users").document(email!).collection("tickets").document(show!)
        //Set data...
        
        //Set data at the defined location
        userTicketRef.setData([
            "ticketID": UID!,
            "show": show!,
            "seats": seats!,
            "tickets": tickets!,
            "date": date!,
            "attendance": false
            //Handle errors...
        ]) { err in //Define error variable
            //Validate error
            if err != nil { //If the error is not empty
                print(err?.localizedDescription as Any) //Output the error
            } else //No error returned
            {
                self.initialiseForm() //Send the form details to the Ruby back-end
                //Transition user back to the home page of the play
                self.downloadTicket()
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getUID() //Load current UID
        loadUser() //Load user details
        loadVenue() //Load venue details
        //Assign labels as variables passed from previous view
        showLabel.text = show
        dateLabel.text = date
        ticketsLabel.text = tickets
        seatsLabel.text = seats
        emailLabel.text = email
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
    
    func loadVenue() //Load venue details from Firestore database
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
                self.venue = dictionary["venue"] as? String
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
    
    
    func initialiseForm()
    {
        let formName = "\(String(describing: self.firstName!)) \(String(describing:self.lastName!))"
        let formEmail = email!
        let formSeatRef = self.seatsLabel.text!
        let formShow = self.showLabel.text!
        let formVenue = self.venue ?? "Empty Space"
        let formDate = self.dateLabel.text!
        
        let formFields: [String: String] = ["user[name]":formName, "user[email]":formEmail, "user[seatRef]":formSeatRef, "user[show]": formShow, "user[venue]": formVenue, "user[date]": formDate]
        
        //API Request function, taking the endpoint and method as parameters
        let POST = HTTPMethod.post
        Alamofire.request(self.APIEndpoint, method: POST, parameters: formFields, encoding: URLEncoding()).responseString { response  in //Closure (No action needed)
            self.downloadTicket()
            self.updateUID()
        }
        

        
    }
    
    func downloadTicket()
    {
        //Define URL for HTTP GET request with UID + pass suffix
        let ticketEndpoint = APIEndpoint+"/\(UID!)/pass.pkpass"
        
        //Send request, with 'GET' method, default encoding and no form fields
        Alamofire.request(ticketEndpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in //Open closure to handle errors and results
                //Error Handling & Converting JSON data to pass
                let pass = try? PKPass(data: response.data!)
                //Results handling
                let pkvc = PKAddPassesViewController(pass: pass!) //Create temporary view to present downloaded pass
                pkvc!.delegate = self //Set delegate to current class
                //Present temporary view to user
                self.present(pkvc!, animated: true, completion: {() -> Void in
                    print("presented pkvc") //Trace output, executes once the temporary view has completed its animation
                })
                self.updateUID()
                let  vc =  self.navigationController?.viewControllers[2]
                self.navigationController?.popToViewController(vc!, animated: true)
    
        }
    }

    //Executes when user selects the add or cancel button
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController)
    {
        //Dismiss view
        controller.dismiss(animated: true, completion: nil)
    }
}

