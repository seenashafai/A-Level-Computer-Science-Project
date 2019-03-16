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
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var dbReviews = [Review]()
    var db: Firestore!
    var showFuncs = showFunctions()
    var user = FirebaseUser()
    var show: Show?
    var alerts = Alerts()
    var dateIndex: Int?
    
    //MARK: - Firebase Queries
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set query to location of reviews in database
        let query = db.collection("shows").document(show!.name).collection(String(dateIndex!)).document("reviews").collection("userReviews")
        self.listener =  query.addSnapshotListener { (documents, error) in //Attach listener
            guard let snapshot = documents else { //Validate that result is not nil
                print("Error fetching documents results: \(error!)") //Output error if result is nil
                return //Exit function
            }
            
            //Map results into Review class structure
            let results = snapshot.documents.map { (document) -> Review in
                if let review = Review(dictionary: document.data()) { //Convert dictionary to Review object
                    return review //Return Review object
                } else { //Mapping failed- incompatible data. Forced fatal error
                    fatalError("Unable to initialize type \(Review.self) with dictionary \(document.data())")
                }
            }
            
            self.dbReviews = results //Update the reviews array with the data from the database
            self.tableView.reloadData() //Refresh tableview to output updated array data
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore() //Instantiate database
        self.tableView.delegate = self //Set table delegate
        self.tableView.dataSource = self //Set table datasource
    }

    //TableView Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //TableView Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbReviews.count //Number of rows in table
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReviewTableViewCell
       
        let review: Review! //Define empty review object
        review = dbReviews[indexPath.row] //Retrieve review details from array and cell index
        cell.cellNameLabel.text = String(review.email) //Assign review email to cell label
        cell.cosmosView.rating = Double(review.starRating) //Assign review star rating to Cosmos view
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let review: Review! //Define empty review object
        review = dbReviews[indexPath.row] //Retrieve review details from array and cell index
        if review.description != "" {
            //Instantiate popup view controller
            let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as! PopUpViewController
            //Add popup view into the current view
            self.addChild(popUpVC)
            //Set the popup view frame as the frame of the current view
            popUpVC.view.frame = self.view.frame
            //Set the text field of the popup view as the review description
            popUpVC.textView.text = review.description
            //Add popup view as subview
            self.view.addSubview(popUpVC.view)
            //Set to parent
            popUpVC.didMove(toParent: self)
            

        } else {
            //Present alert if there is no description string
        }
    }
}
