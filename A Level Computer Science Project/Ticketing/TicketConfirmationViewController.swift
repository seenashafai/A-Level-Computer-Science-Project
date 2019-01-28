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

    var db: Firestore!
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var transaction = [Transaction]()
    var user = FirebaseUser()
    let auth = Validation()
    let barcode = Barcode()
    let alerts = Alerts()
    var global = Global()
  
    var dateIndex: Int?
    var currentTransaction: Int?
    let APIEndpoint = "http://ftpkdist.serveo.net/users"

    //MARK: - User Properties
    var firstName: String?
    var lastName: String?
    var house: String?
    var block: String?
    var venue: String?
    var ticketsBooked: Int?
    var showsBookedArray: [String]?
    var showAttendanceDict: [String: Any] = [:]
    
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ticketsLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var houseLabel: UILabel!
    
    @IBAction func finishAction(_ sender: Any) {
        guard auth.authenticateUser(reason: "Use your fingerprint to validate your booking") == true else {print("gtfo"); return}
            //HUD.show(HUDContentType.systemActivity)

            let email = self.user.getCurrentUserEmail()
            loadUser()
            loadVenue()
            let userTicketRef = db.collection("users").document(email).collection("tickets").document(showLabel.text!)
            userTicketRef.setData([
                "ticketID": currentTransaction,
                "dateIndex": dateIndex,
                "show": showLabel.text!,
                "seats": seatsLabel.text!,
                "tickets": ticketsLabel.text!,
                "date": dateLabel.text!,
                "attendance": false
            ]) { err in
                if err != nil {
                    print("errorino", err?.localizedDescription as Any)
                    HUD.flash(HUDContentType.error)
                } else
                {
                    self.db.collection("transactions").document("currentTransaction").delete()
                        { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Transaction successfully solidified!")
                                let userShowRef = self.db.collection("users").document(email)
                                self.showAttendanceDict[(self.showLabel.text)!] = false
                                userShowRef.updateData([
                                    "ticketsBooked": (self.ticketsBooked! + 1),
                                    "showsBookedArray": FieldValue.arrayUnion([self.showLabel!.text]),
                                    "showAttendance": self.showAttendanceDict

                                    ])
                            }
                    }
                   // HUD.flash(HUDContentType.success, delay: 0.5)
                    self.delayWithSeconds(0.2)
                    {
                        let formName = "\(self.firstName!) \(self.lastName!)"
                        let formEmail = email
                        let formSeatRef = self.seatsLabel.text!
                        let formShow = self.showLabel.text!
                        let formVenue = self.venue!
                        let formDate = self.dateLabel.text!
                        let formDateIndex = String(self.dateIndex!)
                        
                        let formFields: [String: String] = ["user[name]":formName, "user[email]":formEmail, "user[seatRef]":formSeatRef, "user[show]": formShow, "user[venue]": formVenue, "user[date]": formDate, "user[dateIndex]": formDateIndex]
                        
                        Alamofire.request(self.APIEndpoint, method: HTTPMethod.post, parameters: formFields, encoding: URLEncoding()).responseString { response  in
                            print(response.request?.httpBody)
                            print(response.request?.httpBody.debugDescription)
                            print(response.request, "POSTRequest")
                            
                            print(response.debugDescription)
                            print(response.result)
                            print(response.result.value, "val")
                            
                        }
                    }
                    
                    
                    
                    //self.barcode.sendJSONRequestWithoutCompletionHandler(withMethod: "POST", APIEndpoint: self.APIEndpoint, path: "/users/", formFields: formFields)

                   
                    
                   

                    self.presentActionSheet()
                    let  vc =  self.navigationController?.viewControllers[2]
                    self.navigationController?.popToViewController(vc!, animated: true)
                    print("success/dome")
                    }
                }
            }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.query = baseQuery()
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Transaction in
                if let transaction = Transaction(dictionary: document.data()) {
                    return transaction
                } else {
                    print(document.data().debugDescription, "docDebugDesc")
                }
                return self.transaction[0]
            }
            
            self.transaction = results
            self.documents = snapshot.documents
        }
        
        delayWithSeconds(0.2)
        {
            self.readTransaction()
        }


        // Do any additional setup after loading the view.
    }
    
    func loadUser()
    {
        let email = emailLabel.text
        let userRef = db.collection("users").document(email!)
        userRef.getDocument {(documentSnapshot, error) in
            if let error = error
            {
                print(error.localizedDescription, "userRrror")
                return
            }
            if let document = documentSnapshot {
                self.ticketsBooked = document.data()!["ticketsBooked"] as! Int
                self.firstName = document.data()!["firstName"] as! String
                self.lastName = document.data()!["lastName"] as! String
                self.block = document.data()!["block"] as! String
                self.house = document.data()!["house"] as! String
                self.showAttendanceDict = document.data()!["showAttendance"] as! [String: Any]
            }
        }
        print(firstName, "data")
        
        
        
    }
    
    func loadVenue()
    {
        let show = showLabel.text!
        let showRef = db.collection("shows").document(show)
        showRef.getDocument {(documentSnapshot, error) in
            if let error = error
            {
                print(error.localizedDescription, "venueError")
                return
            }
            if let document = documentSnapshot {
                print(document.data()!["venue"], "venue")
                self.venue = document.data()!["venue"] as! String
            }
        }

    }
    
    func loadStatistics()
    {
        let show = showLabel.text!
        let showRef = db.collection("shows").document(show)
        showRef.getDocument {(documentSnapshot, error) in
            if let error = error
            {
                print(error.localizedDescription, "venueError")
                return
            }
            if let document = documentSnapshot {
                print(document.data()!["venue"], "venue")
                self.venue = document.data()!["venue"] as! String
            }
        }
    }
    
    func getTransactionID() -> Int
    {
        var currentTransactionID: Int = 0
        let transactionRef = db.collection("properties").document("transactions")
        transactionRef.getDocument {(documentSnapshot, error) in
            if let error = error
            {
                print(error.localizedDescription, "transaction retrieval error")
                return
            }
            if let document = documentSnapshot {
                print(document.data()!["runningTotal"], "runningTotal")
                currentTransactionID = document.data()!["runningTotal"] as! Int
            }
        }
        return currentTransactionID
    }
    
    func presentActionSheet()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Download Ticket Now", style: .default, handler: {(UIAlertAction) in
            self.downloadTicket2()
        }))
        alert.addAction(UIAlertAction(title: "Recieve Ticket via Email", style: .default, handler: {(UIAlertAction) in
            //self.emailTicket()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        )
        self.present(alert, animated: true, completion: {
            print("completion")
        })
    }
        
    
    func downloadTicket2()
    {
        var uid = currentTransaction
        let url : NSURL! = NSURL(string: "http://ftpkdist.serveo.net/users/\(uid!)/pass.pkpass")
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
                    self.updateCurrentTransaction()
                }
            }
        })
        task.resume()
        
       
    }
    
    fileprivate func baseQuery() -> Query{
        return db.collection("transactions")
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
            }
        }
    }
    
    func updateCurrentTransaction()
    {
        let transactionIDRef = self.db.collection("properties").document("transactions")
        transactionIDRef.updateData([
            "runningTotal": self.currentTransaction! + 1
            ])
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func readTransaction()
    {
        do{
            currentTransaction = transaction[0].transactionID
            house = transaction[0].house
            block = transaction[0].block
            showLabel.text = transaction[0].show
            dateLabel.text = transaction[0].date
            ticketsLabel.text = String(transaction[0].tickets)
            seatsLabel.text = transaction[0].seats.toPrint
            houseLabel.text = transaction[0].house
            emailLabel.text = transaction[0].email
            
        } catch {
            print("ha")
        }
        
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

