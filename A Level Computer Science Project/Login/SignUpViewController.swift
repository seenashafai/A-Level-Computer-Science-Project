//
//  SignUpViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 26/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class SignUpViewController: UIViewController {

    var ref: DatabaseReference!
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBAction func signUpButton(_ sender: Any)
    {
        let email = emailTextField.text
        let password = passwordTextField.text
        let confirmedPassword = confirmPasswordTextField.text
        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        
        
        Auth.auth().createUser(withEmail: email!, password: password!) { (authResult, error) in
            // ...
            if let error = error
            {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        // Do any additional setup after loading the view.
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
