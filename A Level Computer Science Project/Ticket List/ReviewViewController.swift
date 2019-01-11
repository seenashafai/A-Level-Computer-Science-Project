//
//  ReviewViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 11/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Cosmos
import PKHUD
import Firebase
import FirebaseFirestore


class ReviewViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var reviewTextView: UITextView!
    
    //MARK - Properties
    var db: Firestore!
    var ticket: UserTicket?
    var alerts = Alerts()
    var user = FirebaseUser()
    
    @IBAction func submitAction(_ sender: Any) {
        
        let review = reviewTextView.text
        print(reviewTextView.text, "reviewText")
        let starRating = cosmosView.rating
        let strDateIndex = String(ticket!.dateIndex)
        let ratingsRef = db.collection("shows").document((ticket?.show)!).collection(strDateIndex).document("reviews").collection(user.getCurrentUserEmail()).document("review")
        ratingsRef.setData([
            "review": review,
            "starRating": starRating
            ])
        let submittedReviewAlert = UIAlertController(title: "Information", message: "Review successfully submitted. Thanks for your contribution", preferredStyle: .alert)
        submittedReviewAlert.addAction(UIAlertAction(title: "OK", style: .default, handler:
            {   action in //Begin action methods...
                print("doing")
                self.navigationController?.popViewController(animated: true)
        }))
        
        present(submittedReviewAlert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.reviewTextView.delegate = self
        reviewTextView.text = ""

        // Do any additional setup after loading the view.
    }
    

    func UI(_ block: @escaping ()->Void) {
        DispatchQueue.main.async(execute: block)
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
