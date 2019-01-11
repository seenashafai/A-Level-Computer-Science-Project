//
//  ReviewViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 11/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import FirebaseFirestore


class ReviewViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var reviewTextView: UITextView!
    
    //MARK - Properties
    var db: Firestore!
    var ticket: UserTicket?
    
    
    @IBAction func submitAction(_ sender: Any) {
        let review = reviewTextView.text
        print(reviewTextView.text, "reviewText")
        let starRating = cosmosView.rating
        let strDateIndex = String(ticket!.dateIndex)
        let ratingsRef = db.collection("shows").document((ticket?.show)!).collection(strDateIndex).document("reviews")
        ratingsRef.setData([
            "review": review,
            "starRating": starRating
            ])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.reviewTextView.delegate = self
        reviewTextView.text = ""

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
