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
    var validation = Validation()
    
    //MARK: - IBOutlets
    
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBAction func signUpButton(_ sender: Any)
    {
        signUpValidation()
    }
    
    func createUser() {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            // ...
            guard let _ = authResult?.user.email, error == nil else
            {
                print(error!.localizedDescription)
                let localizedErrorAlert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                localizedErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(localizedErrorAlert, animated: true)
                return
            }
            print("account created successfully")
            let registrationSuccessful = UIAlertController(title: "Success", message: "Account has successfully been created. Please sign in with your new credentials", preferredStyle: .alert)
            registrationSuccessful.addAction(UIAlertAction(title: "OK", style: .default, handler:
                {action in self.navigationController?.popViewController(animated: true)
            }))
            self.present(registrationSuccessful, animated: true)
        }
    }
    
    func signUpValidation()
    {
        var allPresent: Bool = true
        for textField in self.textFields
        {
            if textField.text == ""
            {
                print("empty", textField.tag)
                let emptyFieldAlert = UIAlertController(title: "Validation Error", message: "Please do not leave any fields empty", preferredStyle: .alert)
                emptyFieldAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emptyFieldAlert, animated: true)
                allPresent = false
            }
        }
        if allPresent == true
        {
            if validation.isValueMatch(str1: passwordTextField.text!, str2: confirmPasswordTextField.text!) == false
            {
                print("Passwords do not match")
                let nonMatchingPassAlert = UIAlertController(title: "Validation Error", message: "Your passwords do not match. Please try again", preferredStyle: .alert)
                nonMatchingPassAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(nonMatchingPassAlert, animated: true)
            }
            if validation.isValidEmail(emailStr: emailTextField.text!) == false
            {
                print("Email Validation Error")
                let nonMatchingPassAlert = UIAlertController(title: "Validation Error", message: "Your email is not formatted correctly. Please ensure you have entered your email address correctly", preferredStyle: .alert)
                nonMatchingPassAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(nonMatchingPassAlert, animated: true)
            }
            if validation.isValidPass(passStr: passwordTextField.text!) == false
            {
                print("Password Validation Error")
                let nonMatchingPassAlert = UIAlertController(title: "Validation Error", message: "Your password is not acceptable. Please ensure you have fulfilfed the required criteria for a strong password", preferredStyle: .alert)
                nonMatchingPassAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(nonMatchingPassAlert, animated: true)
            }
            else
            {
                createUser()
            }
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    

    func createAlerts()
    {
        
    }

}
