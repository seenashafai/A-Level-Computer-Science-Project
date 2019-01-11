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

class TicketDetailsViewController: UIViewController, PKAddPassesViewControllerDelegate {

    //MARK: - IBOutlets
    @IBOutlet weak var showTextLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var ticketsTextLabel: UILabel!
    @IBOutlet weak var seatsTextLabel: UILabel!
    @IBOutlet weak var attendanceTextLabel: UILabel!
    
    //MARK: - Properties
    var ticket: UserTicket?
    var showName: String?
    var showFuncs = showFunctions()
    var db: Firestore!
    var isUserSignedIn: Bool = false
    var editable: Bool = false
    let alerts = Alerts()
    
    @IBOutlet weak var addPassButton: UIButton!
    @IBAction func addPassAction(_ sender: Any) {
        print("pressed")
        downloadTicket2()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        showTextLabel.text = ticket?.show
        dateTextLabel.text = ticket?.date
        ticketsTextLabel.text = ticket?.tickets
        seatsTextLabel.text = ticket?.seats
        if ticket?.attendance == true
        {
            attendanceTextLabel.text = "True"
        } else {
            attendanceTextLabel.text = "False"
            reviewOutlet.isUserInteractionEnabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    func downloadTicket2()
    {
        var uid = ticket?.ticketID
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
                    
                }
            }
        })
        task.resume()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReviewView"
        {
            let destinationVC = segue.destination as! ReviewViewController
            destinationVC.ticket = ticket
        }
    }

}
