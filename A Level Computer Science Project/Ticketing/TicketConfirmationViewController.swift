//
//  TicketConfirmationViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 26/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD
import LocalAuthentication

class TicketConfirmationViewController: UIViewController {

    var db: Firestore!
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var transaction = [Transaction]()
    var user = FirebaseUser()
    let auth = Validation()
    
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ticketsLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var houseLabel: UILabel!
    
    @IBAction func finishAction(_ sender: Any) {
        if auth.authenticateUser(reason: "Use your fingerprint to validate your booking") == true
        {
                HUD.show(HUDContentType.systemActivity)
            
            let email = user.getCurrentUserEmail()
            let userTicketRef = db.collection("users").document(email).collection("tickets").document(showLabel.text!)
            userTicketRef.setData([
                "show": showLabel.text!,
                "seats": seatsLabel.text!,
                "tickets": ticketsLabel.text!,
                "date": dateLabel.text!
            ]) { err in
                if err != nil {
                    print("errorino", err?.localizedDescription as Any)
                    HUD.flash(HUDContentType.error)
                } else
                {
                    self.db.collection("transactions").document("currentTransaction").delete()
                        { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                    }
                    HUD.flash(HUDContentType.success, delay: 0.5)
                    let  vc =  self.navigationController?.viewControllers[2]
                    self.navigationController?.popToViewController(vc!, animated: true)
                    print("success/dome")
                    }
                }
            }
        else
        {
            print("gtfo")
        }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.query = baseQuery()


        // Do any additional setup after loading the view.
    }
    
    fileprivate func baseQuery() -> Query{
        return db.collection("transactions")
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Transaction in
                if let transaction = Transaction(dictionary: document.data()) {
                    return transaction
                } else {
                    print(document.data().debugDescription, "docDebugDesc")
                }
                return self.transaction[0]
            }
            
            self.transaction = results
            self.documents = snapshot.documents
        }
        
        delayWithSeconds(0.2)
        {
            self.readTransaction()
        }
        
    }
    
    func readTransaction()
    {
        showLabel.text = transaction[0].show
        dateLabel.text = transaction[0].date
        ticketsLabel.text = String(transaction[0].tickets)
        seatsLabel.text = transaction[0].seats.description
        houseLabel.text = transaction[0].house
        emailLabel.text = transaction[0].email
        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
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
