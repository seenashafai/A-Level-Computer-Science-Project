//
//  LoginViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 17/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import FirebaseAuth
import MaterialComponents.MaterialSnackbar

class LoginViewController: UIViewController {
    
    var alerts = Alerts()
    var user = FirebaseUser()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    @IBAction func signInButton(_ sender: Any)
    {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if textBoxIsFilled() == false
        {
            
        }
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (authResult, error) in
            // ...
            if let error = error
            {
                self.present(self.alerts.localizedErrorAlertController(message: (error.localizedDescription)), animated: true)
                return
            }
            else
            {
                print("success")
                self.performSegue(withIdentifier: "toShowList", sender: self)
            }
        }
    }
    
    //MARK: - Private Instance Methofs
    func textBoxIsFilled() -> Bool
    {
        var allPresent: Bool = true
        for textField in self.textFields
        {
            if textField.text == ""
            {
                print("empty", textField.tag)
                self.present(self.alerts.validationErrorAlertController(message: "Please do not leave any fields empty"), animated: true)
                allPresent = false
            }
        }
        return allPresent
    }
    
    
    
    
   /*
    func isUserSignedIn() -> Bool
    {
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser?.email, "JEFF")
            return true
        } else {
            return false
        }
    }
    
    func getCurrentUser() -> String
    {
        var userEmail: String = ""
        if isUserSignedIn() == true
        {
            userEmail = (Auth.auth().currentUser?.email)!
            print(userEmail)
            return userEmail as! String
            
        }
        else
        {
            print("not signed in")
        }
        return userEmail
    }
    */
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        self.navigationController?.isNavigationBarHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if user.isUserSignedIn() == true
        {
            do {
                let message = MDCSnackbarMessage()
                message.text = "Signing out current user \(user.getCurrentUserDisplayName())"
                MDCSnackbarManager.show(message)
                try Auth.auth().signOut()

                }
            catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            }
        }
        else
        {
            print("User is not signed in")
        }
    }


    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignUpView"
        {
            if user.isUserSignedIn() == true {
            do {
                try Auth.auth().signOut()
                print("User signed out")
                
            }
            catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            }
        }
    }

}
