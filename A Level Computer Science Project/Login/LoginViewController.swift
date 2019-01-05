//
//  LoginViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 17/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MaterialComponents.MaterialSnackbar

class LoginViewController: UIViewController {
    
    //MARK: - Properties
    var alerts = Alerts()
    var user = FirebaseUser()
    var db: Firestore!
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var isAdmin: Bool?
    

    
    //MARK: - IB Links
    
    //Textfields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    //Autofill details
    @IBAction func autoFill(_ sender: Any) {
        emailTextField.text = "seenas@btinternet.com"
        passwordTextField.text = "Test123"
    }
    
    //Sign-in button action
    @IBAction func signInButton(_ sender: Any)
    {
        let email = emailTextField.text
        let password = passwordTextField.text

        Auth.auth().signIn(withEmail: email!, password: password!)
        { (authResult, error) in
            // ...
            if let error = error
            {
                self.present(self.alerts.localizedErrorAlertController(message: (error.localizedDescription)), animated: true)
                return
            }
            else
            {
                print("success")
                let userAdminRef = self.db.collection("users").document(email!)
                userAdminRef.getDocument(completion: { (document, error) in
                    if let document = document, document.exists {
                        print(document.data()!["admin"] as! Int, "asInt")
                        if document.data()!["admin"] as? Bool == true {
                            self.isAdmin = true
                            print(self.isAdmin, "adminPrint")
                        } else {
                            self.isAdmin = false
                        }
                    }
                })
                
                self.performSegue(withIdentifier: "toShowList", sender: self)
            }
        }
    }
    
    //MARK: - Private Instance Methods
    //Check if textbox is empty
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
    
    //MARK: - setFirebaseSettings
    func setFirebaseSettings()
    {
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        settings.isPersistenceEnabled = false
    }
    
    
    //MARK: - Firebase Query methods
    
    fileprivate func baseQuery() -> Query{
        return db.collection("users")
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
            }
        }
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFirebaseSettings()
        db = Firestore.firestore()
        self.query = baseQuery()
        emailTextField.keyboardType = .emailAddress
        passwordTextField.textContentType = .password
        self.navigationController?.isNavigationBarHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // self.listener.remove()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Present signing out snackbar
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


    
    func loadFromFirestore() {
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Ticket in
                print(document.data(), "docData")
                print(document, "doc")
                if let ticket = Ticket(dictionary: document.data()) {
                    return ticket
                } else {
                    fatalError("Unable to initialize type \(Ticket.self) with dictionary \(document.data())")
                }
            }
            
            self.documents = snapshot.documents
            print(self.user)
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
        if segue.identifier == "toShowList"
        {
            var destVC = segue.destination as! ShowListTableViewController
            //destVC.userIsAdmin = isAdmin
            print(isAdmin, "isAdmin")
            
        }
    }

}
