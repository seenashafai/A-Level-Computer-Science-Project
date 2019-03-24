//  SignUpViewController.swift
//  A Level Computer Science Project
//  Copyright © 2018 Seena Shafai. All rights reserved.

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK: - Properties
    //Database
    var db: Firestore!

    //Instantiations
    var validation = Validation()
    var alerts = Alerts()
    var user = FirebaseUser()
    
    //Class Variables
    var houseInitialsArray = [String]()
    var houseSelected: String?
    var blocksArray = [String]()
    var blockSelected: String?
    
    //MARK: - IB Links
    //Text Fields
    @IBOutlet var textFields: [UITextField]! //Textfield collection
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //Sign-up button action
    @IBAction func signUpButton(_ sender: Any)
    {
        //Make sure house picker isn't set at first index ('Please select house...')
        guard housePickerView.selectedRow(inComponent: 0) != 0 else
        {
            //Present alert to show that the first house value is a placeholder and cannot be selected
            self.present(alerts.invalidHouseErrorAlertController(), animated: true)
            return
        }
        signUpValidation() //Execute validation
    }
    
    //MARK: - FirebaseAuth Methods
    func createUser()
    {
        //Authenticate with email and password
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!)
        { (authResult, error) in //CLOSURE
            // Handle result of authentication
            guard let _ = authResult?.user.email, error == nil else //Checking from API errors returned within closure
            {
                //Output API alert if necessary
                self.present(self.alerts.localizedErrorAlertController(message: (error?.localizedDescription)!), animated: true)
                return
            }
            print("account created successfully") //Trace statement
            //Create alert to inform user that their account has successfully been created
            let registrationSuccessful = UIAlertController(title: "Success", message: "Account has successfully been created" +
                "A verification email has been sent to you you will be unable to book tickets until you have verified your account.", preferredStyle: .alert)
            registrationSuccessful.addAction(UIAlertAction(title: "OK", style: .default, handler:
                {action in }))
            //Show alert on screen
            self.present(registrationSuccessful, animated: true)
        
        }
        user.sendUserValidationEmail() //Validate user with a validation email.
        
        //Collect user information into dictionary and set data to user's email node within the 'users' root node
        db.collection("users").document(emailTextField.text!).setData([
            "firstName": firstNameTextField.text!,
            "lastName": lastNameTextField.text!,
            "emailAddress": emailTextField.text!,
            "house": houseSelected!,
            "block": blockSelected!,
            "admin": false
            //Error handling
        ]) { err in //Initialised by the API
            if err != nil { //Executes if API returns an error
                print(err?.localizedDescription as Any) //Output API error message
            } else
            {
                print("success") //Trace statement
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    //Picker view connections
    @IBOutlet weak var housePickerView: UIPickerView!
    @IBOutlet weak var blockPickerView: UIPickerView!
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 //1 Section in picker
    }
    
    //Number of rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == housePickerView
        {
            //Number of elements in house array (25 + placeholder)
            return houseInitialsArray.count
        }
        if pickerView == blockPickerView
        {
            //Number of elements in block array
            return blocksArray.count
        }
        return 0 //Default (if error occurs)
    }
    
    //Title for row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == housePickerView
        {
            //Return current iteration of house array
            return houseInitialsArray[row]
        }
        if pickerView == blockPickerView
        {
            //Return current iteration of block array
            return blocksArray[row]
        }
        return "" //Default (if error occurs)
    }
    
    //Determine which row is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == housePickerView
        {
            //Assign selected house using row subscript to local variable
            houseSelected = houseInitialsArray[row]
        }
        if pickerView == blockPickerView
        {
            //Assign selected block using row subscript to local variable
            blockSelected = blocksArray[row]
        }
    }
    
    //MARK: - Local validation
    func signUpValidation()
    {
        //Presence check
        var allPresent: Bool = true
        for textField in self.textFields //Iterate through textfields
        {
            if textField.text == "" //Validate that the textfield being iterated through is not empty
            {
                //Otherwise, output the error message for a presence failure
                self.present(self.alerts.validationErrorAlertController(message: "Please do not leave any fields empty"), animated: true)
                allPresent = false //Set validation boolean to false, to halt the progress of the function
            }
        }
        //Continue if presence checking is successful
        if allPresent == true
        {
            //Validate that both password fields match
            if validation.isValueMatch(str1: passwordTextField.text!, str2: confirmPasswordTextField.text!) == false
            {
                print("Passwords do not match") //If not, output error
                self.present(self.alerts.validationErrorAlertController(message: "Your passwords do not match. Please try again"), animated: true)
            }
            //Validate that the email is correctly formatted
            else if validation.isValidEmail(emailStr: emailTextField.text!) == false
            {
                print("Email Validation Error") //If not, output error
                self.present(self.alerts.validationErrorAlertController(message: "Your email is not formatted correctly. Please ensure you have entered your email address correctly"), animated: true)
            }
            //Validate that the password meets the strength criteria
            else if validation.isValidPass(passStr: passwordTextField.text!) == false
            {
                print("Password Validation Error") //If not, output error
                self.present(self.alerts.validationErrorAlertController(message: "Your password is not acceptable. Please ensure you have fulfilfed the required criteria for a strong password"), animated: true)
            }
            else
            {
                createUser()
            }
        }
    }
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Open database session
        db = Firestore.firestore()
        //Define list of houses
        houseInitialsArray = ["Please select a house...","ABH", "AMM", "ASR", "AW", "BJH", "Coll", "DWG", "EJNR", "HWTA", "JCAJ", "JD", "JDM",
                              "JDN", "JMG", "JMO\'B", "JRBS", "MGHM", "NA", "NCWS", "NPTL", "PAH", "PEPW", "PGW", "RDO-C", "SPH"]
        //Define list of blocks
        blocksArray = ["B", "C", "D", "E", "F"]
    }
}
