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

class ShowDetailViewController: UIViewController {

    var isUserSignedIn: Bool = false
    
    @IBAction func toTicketPortal(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser?.email)
            isUserSignedIn = true
        } else {
            let userNotSignedIn = UIAlertController(title: "Error", message: "You must be signed in to order tickets. Please proceed to create an account", preferredStyle: .alert)
            userNotSignedIn.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                print("cancel")
            }))
            userNotSignedIn.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { action in
                print("signin")
            }))
            self.present(userNotSignedIn, animated: true)
        }
    }
    
    
    var showTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = showTitle

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let id = identifier {
            if id == "toTicketPortal" {
                print("im already tracerrrrrr")
                if isUserSignedIn != true {
                    print("nope")
                    return false
                }
                else {return true}
                
            }
        }
        return true
    }
    
  
}
