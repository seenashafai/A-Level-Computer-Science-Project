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
    var ticket: UserTicket? //Pre-loaded from previous class
    var db: Firestore!
    
    var alerts = Alerts()
    var user = FirebaseUser()
    
    var ratingsArray: [Double]?
    
    @IBAction func submitAction(_ sender: Any) {
        
        //get Review data
        let review = reviewTextView.text //Get description
        let starRating: Double = cosmosView.rating //Get star rating
        let dateIndex = String(ticket!.dateIndex) //Get date index and convert to String
        
        let email = user.getCurrentUserEmail() //Get email of current user to use as node name
        
        //Upload details to database with email as node name: shows -> show name -> reviews -> userReviews -> email
        let ratingsRef = db.collection("shows").document((ticket?.show)!).collection(dateIndex).document("reviews").collection("userReviews").document(email)
        
        //set data in query location
        ratingsRef.setData([
            "review": review!, //Add review
            "starRating": starRating, //Add star rating
            "email": email //Add email
            ])
        
        //Create reference for the 4th date index (total show statistics and reviews)
        let totalRef = db.collection("shows").document((ticket?.show)!).collection("4").document("reviews").collection("userReviews").document(email)
        
        //set data in query location
        totalRef.setData([
            "review": review!, //Add review
            "starRating": starRating, //Add star rating
            "email": email //Add email
            ])
        
    }
    
    func getReviewsArray()
    {
        let strDateIndex = String(ticket!.dateIndex)
        let ratingsRef = db.collection("shows").document((ticket?.show)!).collection(strDateIndex).document("reviews")
        ratingsRef.getDocument {( documentSnapshot, error) in
            if let document = documentSnapshot {
                self.ratingsArray = document["ratingsArray"] as? [Double] ?? [0.0]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getReviewsArray()
        self.reviewTextView.delegate = self
        reviewTextView.text = ""
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
}
