//
//  LoginViewController.swift
//  A Level Computer Science Project
//  Copyright © 2018 Seena Shafai. All rights reserved.

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    //MARK: - Properties
    var alerts = Alerts()
    var user = FirebaseUser()
    var db: Firestore!
    var admin: Bool?

    //MARK: - IB Links
    
    //Textfields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!

    //Sign-in button action
    @IBAction func signInButton(_ sender: Any)
    {
        //Presence check
        guard textBoxIsFilled() == true else
        {
            //Failed
            return
        }
        let email = emailTextField.text //Get email from text field
        let password = passwordTextField.text //Get password from text field
        //Initiare login authentication from Firebase API
        Auth.auth().signIn(withEmail: email!, password: password!)
        { (authResult, error) in
            // Check for error returned by API
            if let error = error
            {
                //Output error from API to user
                self.present(self.alerts.localizedErrorAlertController(message: (error.localizedDescription)), animated: true)
                return
            }
            else //No error returned by the API
            {
                self.checkUserAdmin()
                print("successful") //Trace output

            }
        }
    }
    
    //Check if textbox is empty
    func textBoxIsFilled() -> Bool
    {
        //Define presence boolean
        var allPresent: Bool = true
        for textField in self.textFields //Iterate through text fields
        {
            if textField.text == "" //Validate that the text is not empty
            {
                //Output error from API to user
                self.present(self.alerts.validationErrorAlertController(message: "Please do not leave any fields empty"), animated: true)
                allPresent = false //Set presence boolean to false
            }
        }
        //Return presence boolean
        return allPresent
    }

    func checkUserAdmin()
    {
        let email = Auth.auth().currentUser?.email
        let userRef = db.collection("users").document(email!)
        userRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                let dict = document.data()!
                self.admin = dict["admin"] as? Bool
                print(self.admin, "ad")
                //Take user to show list when successful
                self.performSegue(withIdentifier: "toShowList", sender: self)
            }
        }
    }
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShowList"
        {
            let destVC = segue.destination as! ShowListTableViewController
            destVC.userIsAdmin = admin
        }
    }
}
