//
//  SignUpViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 26/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore



class SignUpViewController: UIViewController {

    //MARK: - Properties
    var db: Firestore!
    var validation = Validation()
    var alerts = Alerts()
    var user = FirebaseUser()
    
    //MARK: - IB Links
    
    //Text Fields
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //Sign-up button action
    @IBAction func signUpButton(_ sender: Any)
    {
        signUpValidation()
    }
    
    //MARK: - FirebaseAuth Methods
    func createUser()
    {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!)
        { (authResult, error) in
            // ...
            guard let _ = authResult?.user.email, error == nil else
            {
                self.present(self.alerts.localizedErrorAlertController(message: (error?.localizedDescription)!), animated: true)
                return
            }
            print("account created successfully")
            let registrationSuccessful = UIAlertController(title: "Success", message: "Account has successfully been created. A verification email has been sent to you; you will be unable to book tickets until you have verified your account.", preferredStyle: .alert)
            registrationSuccessful.addAction(UIAlertAction(title: "OK", style: .default, handler:
                {action in self.navigationController?.popViewController(animated: true)
            }))
            self.present(registrationSuccessful, animated: true)
        
        }
        user.sendUserValidationEmail()
        
        //var _: DocumentReference? = nil
        db.collection("users").document(emailTextField.text!).setData([
            "firstName": firstNameTextField.text!,
            "lastName": lastNameTextField.text!,
            "emailAddress": emailTextField.text!,
            "admin": false
            
        ]) { err in
            if err != nil {
                print("error", err?.localizedDescription)
            } else
            {
                print("success")
            }
        }
    }
    
    //MARK: - Local validation
    func signUpValidation()
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
        if allPresent == true
        {
            if validation.isValueMatch(str1: passwordTextField.text!, str2: confirmPasswordTextField.text!) == false
            {
                print("Passwords do not match")
                self.present(self.alerts.validationErrorAlertController(message: "Your passwords do not match. Please try again"), animated: true)
            }
            else if validation.isValidEmail(emailStr: emailTextField.text!) == false
            {
                print("Email Validation Error")
                self.present(self.alerts.validationErrorAlertController(message: "Your email is not formatted correctly. Please ensure you have entered your email address correctly"), animated: true)
            }
           else if validation.isValidPass(passStr: passwordTextField.text!) == false
            {
                print("Password Validation Error")
                self.present(self.alerts.validationErrorAlertController(message: "Your password is not acceptable. Please ensure you have fulfilfed the required criteria for a strong password"), animated: true)
            }
            else
            {
                createUser()
            }
        }
    }
    
    //Change request for displayName
    /*
    private func changeRequest()
    {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = firstNameTextField.text
        print("changeRequest")
        changeRequest?.commitChanges { (error) in
            print("displayName update error")
        }
    }
    */
    
    //Dimsiss keyboard on touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.keyboardType = .emailAddress
        if #available(iOS 12.0, *) {
            passwordTextField.textContentType = .newPassword
            confirmPasswordTextField.textContentType = .newPassword
            emailTextField.textContentType = .username
        }
        db = Firestore.firestore()

        // Do any additional setup after loading the view.
    }
}
