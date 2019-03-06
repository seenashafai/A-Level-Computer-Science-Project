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
    let APIEndpoint = "http://localhost:6789/users"
    var UID: Int?

    
    
    var db: Firestore!
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var transaction = [Transaction]()
    var user = FirebaseUser()
    let auth = Validation()
    let barcode = Barcode()
    let alerts = Alerts()
  
    var dateIndex: Int?
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
            loadVenue() //Load venue details
        
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
                    //Wait .2 seconds to allow the database to finish loading the user and venue information
                    self.delayWithSeconds(0.2) {
                        self.initialiseForm() //Send the form details to the Ruby back-end
                    }
                    self.downloadTicket()
                    //Transition user back to the home page of the play
                    self.delayWithSeconds(3) {
                        let  vc =  self.navigationController?.viewControllers[2]
                        self.navigationController?.popToViewController(vc!, animated: true)
                    }
                    }
                }
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
        
        //Define request method as POST
        let POST: HTTPMethod = HTTPMethod.post
        //API Request function, taking the endpoint and method as parameters
        Alamofire.request(self.APIEndpoint, method: POST, parameters: formFields, encoding: URLEncoding()).responseString { response  in //Closure (No action needed)
        }
    }
    
    func downloadTicket()
    {
        let ticketEndpoint = APIEndpoint+"/\(UID!)/pass.pkpass"
        var GET = HTTPMethod.get

        Alamofire.request(ticketEndpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                var error: NSError?
                let pass = try? PKPass(data: response.data!)
                if error != nil {
                    DispatchQueue.main.async {
                        self.present(self.alerts.localizedErrorAlertController(message: (error?.localizedDescription)!), animated: true)
                    }
                }
                else {
                    let passLibrary = PKPassLibrary()
                    if passLibrary.containsPass(pass!) {
                        DispatchQueue.main.async {
                            self.present(self.alerts.alreadyInWalletInfo(), animated: true)
                        }
                    } else {
                        let pkvc = PKAddPassesViewController(pass: pass!)
                        pkvc!.delegate = self
                        self.present(pkvc!, animated: true, completion: {() -> Void in
                            print("presented pkvc")
                        })
                        print("done")
                    }
                }
            }
        }
    
    func downloadTicket2()
    {
        let url : NSURL! = NSURL(string: "\(APIEndpoint)/users/\(UID!)/pass.pkpass")
        let request: NSURLRequest = NSURLRequest(url:
            url as URL)
        print(request.url, "urel")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task : URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            
            var error: NSError?
            let pass = try? PKPass(data: data!)
            if error != nil {
                DispatchQueue.main.async {
                    self.present(self.alerts.localizedErrorAlertController(message: (error?.localizedDescription)!), animated: true)
                }
            }
            else {
                let passLibrary = PKPassLibrary()
                if passLibrary.containsPass(pass!) {
                    DispatchQueue.main.async {
                        self.present(self.alerts.alreadyInWalletInfo(), animated: true)
                    }
                } else {
                    let pkvc = PKAddPassesViewController(pass: pass!)
                    pkvc!.delegate = self
                    self.present(pkvc!, animated: true, completion: {() -> Void in
                        print("presented pkvc")
                        })
                    print("done")
                }
            }
        })
        task.resume()
        
       
    }

    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        
        controller.dismiss(animated: true, completion: nil)

        
            let passAddedToWalletInfo = UIAlertController(title: "Information", message: "Ticket added to Wallet app. Please be prepared to show this ticket at the door", preferredStyle: .alert)
            passAddedToWalletInfo.addAction(UIAlertAction(title: "OK", style: .default, handler:
                {action in
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
            }))
        self.present(passAddedToWalletInfo, animated: true)
    }

    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
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

extension Array {
    var toPrint: String  {
        var str = ""
        
        for element in self {
            if self.count == 1 {
                str = "\(element)"
            } else {
                str += "\(element), "
            }
        }
        return str
    }
}

