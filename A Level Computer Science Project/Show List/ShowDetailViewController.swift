//
//  ShowDetailViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 17/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import CoreLocation
import MapKit

class ShowDetailViewController: UIViewController {

    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    var show: Show?
    var showFuncs = showFunctions()
    
    
    
    //MARK: - Properties
    var db: Firestore!
    var isUserSignedIn: Bool = false
    var user = FirebaseUser()
    
    //MARK: - IB Links
    @IBAction func toTicketPortal(_ sender: Any) {
        if user.isUserSignedIn() == false
        {
            print("NS")
            let userNotSignedIn = UIAlertController(title: "Error", message: "You must be signed in to order tickets. Please proceed to create an account", preferredStyle: .alert)
            userNotSignedIn.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                print("cancel")
            }))
            userNotSignedIn.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { action in
                self.navigationController?.popToRootViewController(animated: true)
                print("signin")
            }))
            self.present(userNotSignedIn, animated: true)
        }
        if user.isUserEmailVerified() == false
        {
            print("NV")
            let userEmailNotVerified = UIAlertController(title: "Error", message: "You may not order tickets until you have verified yout account. Would you like us to re-send the verification email?", preferredStyle: .alert)
            userEmailNotVerified.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                print("cancel")
            }))
            userEmailNotVerified.addAction(UIAlertAction(title: "Re-send", style: .default, handler: { action in
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if let error = error {
                        print(error.localizedDescription, "error")
                    } else
                    {
                        print("email sent")
                    }
                }
                self.navigationController?.popToRootViewController(animated: true)
                print("signin")
            }))
            self.present(userEmailNotVerified, animated: true)
        }
    }
    
    
    var showTitle: String = ""
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = showTitle
       
        db = Firestore.firestore()
        
        let showDetailsRef = db.collection("shows").document(showTitle)
        showDetailsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                print(document.data(), "doc")
                let show = Show(dictionary: document.data()!)
                print(show, "showDict")

            }
        }
        
        let convertedDate = showFuncs.getDateFromEpoch(timeInterval: TimeInterval((show?.date.seconds)!))
        
        venueLabel.text = show?.venue
        directorLabel.text = show?.director
        datesLabel.text = convertedDate
        descriptionTextView.text = show?.description
        

        // Do any additional setup after loading the view.
    }

    // MARK: - Navigation
    
    //Segue preparation
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let id = identifier
        {
            if id == "toTicketPortal"
            {
                if  user.isUserSignedIn() != true
                {
                    print("no user signed in")
                    return false
                }
                if user.isUserEmailVerified() != true
                {
                    print("email not verified")
                    return false
                }
                else
                {
                    return true
                }
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTicketPortal"
        {
            let destinationVC = segue.destination as! TicketPortalViewController
            print(showTitle, "showtitle")
            destinationVC.ticketShowTitle = showTitle
        }
    }
  
}
