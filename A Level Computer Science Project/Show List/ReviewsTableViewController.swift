//
//  ReviewsTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 16/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import MaterialComponents.MaterialSnackbar
import PKHUD

class ReviewsTableViewController: UITableViewController {

    //MARK: - Initialise Firebase Properties
    var listener: ListenerRegistration!
    var dbReviews = [Review]()
    var db: Firestore!
    var showFuncs = showFunctions()
    var user = FirebaseUser()
    var show: Show?
    var alerts = Alerts()
    var dateIndex: Int?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let query =  db.collection("shows").document(show!.name).collection(String(dateIndex!)).document("reviews").collection("userReviews")
        self.listener =  query.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            
            let results = snapshot.documents.map { (document) -> Review in
                if let review = Review(dictionary: document.data()) {
                    print(document.data(), "docData")
                    print(review, "reviewDict")
                    return review
                } else {
                    print(document.data(), "docData")
                    fatalError("Unable to initialize type \(Review.self) with dictionary \(document.data())")
                }
            }
            
            self.dbReviews = results
            self.tableView.reloadData()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dbReviews.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReviewTableViewCell
        let review: Review
        review = dbReviews[indexPath.row]
        cell.cellNameLabel.text = String(review.email)
        cell.cosmosView.rating = Double(review.starRating)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let review: Review
        review = dbReviews[indexPath.row]
        if review.description != "" {
            let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as! PopUpViewController
            self.addChild(popUpVC)
            popUpVC.view.frame = self.view.frame
        
            popUpVC.textView.text = review.description
            self.view.addSubview(popUpVC.view)
            popUpVC.didMove(toParent: self)
        } else {
            self.present(alerts.noReviewDescription(), animated: true)
        }
    }
}
