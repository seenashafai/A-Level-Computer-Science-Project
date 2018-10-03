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
    
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBAction func signUpButton(_ sender: Any)
    {
        presenceCheck()
    }
    
    func createUser() {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            // ...
            guard let _ = authResult?.user.email, error == nil else
            {
                print(error!.localizedDescription)
                return
            }
            print("account created successfully")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func presenceCheck()
    {
        var allPresent: Bool = true
        for textField in self.textFields
        {
            if textField.text == ""
            {
                print("empty", textField.tag)
                allPresent = false
            }
        }
        if allPresent == true
        {
            self.createUser()
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
