//
//  ShowStatsViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 10/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD
import Charts
import Cosmos


class ShowStatsViewController: UIViewController {

    //Class Instances
    var showFuncs = showFunctions()
    
    //Global variables
    var dateIndex: Int?
    
    //UI Features
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var dateSegmentedView: UISegmentedControl!
    
    //Labels
    @IBOutlet weak var ticketHoldersLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var missingLabel: UILabel!
    @IBOutlet weak var pctTurnoutLabel: UILabel!
    @IBOutlet weak var unclaimedTicketsLabel: UILabel!
    @IBOutlet weak var top5Label: UILabel!
    @IBOutlet weak var bottom5Label: UILabel!
    
    //Executes when segmented controller is pressed
    @IBAction func dateSegmentedViewAction(_ sender: Any) {
        //Increment index
        dateIndex = dateSegmentedView.selectedSegmentIndex + 1
        //Execute database call with incremented index
        retrieveRawData(show: (show?.name)!, dateIndex: String(dateIndex!))
    }
    

    
    //MARK: - Properties
    var db: Firestore!
    var show: Show?
    var blockDict: [String: Any] = [:]
    var blockDataEntries = [PieChartDataEntry]()
    var houseDataEntries = [PieChartDataEntry]()
    var starRatingsArray: [Double] = []
    var statsDict: [String: Any] = [:]
    var houseDict: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        retrieveRawData(show: (show?.name)!, dateIndex: String(dateSegmentedView!.selectedSegmentIndex + 1))
        cosmosView.isUserInteractionEnabled = false
        
    }
    
    func updateChart()
    {
        let blockDataB = PieChartDataEntry(value: self.blockDict["B"] as! Double, label: "B") //Assign data and label for B
        let blockDataC = PieChartDataEntry(value: self.blockDict["C"] as! Double, label: "C") //Assign data and label for C
        let blockDataD = PieChartDataEntry(value: self.blockDict["D"] as! Double, label: "D") //Assign data and label for D
        let blockDataE = PieChartDataEntry(value: self.blockDict["E"] as! Double, label: "E") //Assign data and label for E
        let blockDataF = PieChartDataEntry(value: self.blockDict["F"] as! Double, label: "F") //Assign data and label for F
        self.blockDataEntries = [blockDataB, blockDataC, blockDataD, blockDataE, blockDataF] //Create an array of data entries
        
        let chartDataSet = PieChartDataSet(values: blockDataEntries, label: nil) //Convert the array into a 'DataSet' type
        let chartData = PieChartData(dataSet: chartDataSet) //Convert the DataSet to a 'ChartData' type
        let colours = [UIColor.blue, UIColor.red, UIColor.green, UIColor.orange, UIColor.gray] //Set the colours to correspond to each piece of block data
        chartDataSet.colors = colours //Set the colours attribute of the chart to the above defined colours
        
        pieChartView.data = chartData //Set the data of the chart to the 'ChartData' type derived from the original block dictionary
    }
    
    func updateStarRating()
    {
        print(starRatingsArray.debugDescription)
        //Get number of items in array
        let reviewCount = starRatingsArray.count
        //Iterate through the array
        var totalRating: Double = 0
        for rating in starRatingsArray {
            //Add each number to make a total
            totalRating = totalRating + rating
        }
        let average = totalRating/Double(reviewCount)
        cosmosView.rating = average //Assign average rating to cosmos stars
    }
    
    func updateAttributeLabels()
    {
        //Pull ticket holders details
        let ticketHolders = (self.statsDict["ticketHolders"] as! [String]).count
        self.ticketHoldersLabel.text = String(ticketHolders)
        
        //Pull attendees details
        let attendees = (self.statsDict["attendees"] as! Int)
        self.attendeesLabel.text = String(attendees)
        
        //Derive unclaimed ticket value by subtracting number of ticket holders from original
        let availableTickets = self.statsDict["availableTickets"] as! Int
        self.unclaimedTicketsLabel.text = String(availableTickets)
        
        //Derive the number of missing people by subtracting the attendees from the ticket holders
        self.missingLabel.text = String(ticketHolders - attendees)
        //Find the percentage turnout by dividing the attendees by ticket holders, and multiplying by 100.
        let pctTurnout = (Float(attendees)/Float(ticketHolders) * 100)
        self.pctTurnoutLabel.text = (String(pctTurnout) + "%")
    }
    
    

    func updateHouseList()
    {
        //Sort dictionary from high to low
        let sortedHouseDict = self.houseDict.sorted(by: {$0.value > $1.value} )
        //Sort dictionary from low to high
        let reverseSortedHouseDict = self.houseDict.sorted(by: {$0.value < $1.value})
        //Initialise arrays for storing top/bottom 5 houses
        var top5HouseArray: [String] = []
        var bottom5HouseArray: [String] = []
        //Loop through the first five values of the sorted arrays
        for i in 0..<5
        {
            if sortedHouseDict[i].value > 0 //Make sure top 5 sorted values don't include 0
            {
                top5HouseArray.append(sortedHouseDict[i].key) //Add top sorted values to new array
            }
            bottom5HouseArray.append(reverseSortedHouseDict[i].key) //Add top reverse sorted values to new array
        }
        top5Label.text = top5HouseArray.description //Assign top 5 houses to label
        bottom5Label.text = bottom5HouseArray.description //Assign bottom 5 houses to label
    }
    
    func retrieveRawData(show: String, dateIndex: String) //Input show name and date index
    {
        //Get block statistics
        //Set query to blockStats node
        let blockStatsRef = db.collection("shows").document(show).collection(dateIndex).document("blockStats")
        blockStatsRef.getDocument {(documentSnapshot, error) in //retrieve data from query location
            if let document = documentSnapshot { //Validate data
                self.blockDict = document.data()! //Assign retrieved dictionary to local variable
                self.updateChart() //Execute method to create piChart from data
            }
        }
        
        let houseStatsRef = db.collection("shows").document(show).collection(dateIndex).document("houseStats")
        houseStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.houseDict = document.data()! as! [String: Int]
                print(self.houseDict.debugDescription)
                self.updateHouseList()
            }
        }
        
        //Set query to reviews section in database
        let totalRatingsRef = db.collection("shows").document(show).collection(dateIndex).document("reviews")
        totalRatingsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot { //Validate that the returned array isn't empty
                self.starRatingsArray = (document["ratingsArray"] as? Array ?? [0.0]) //Assign the returned array to a local variable
                self.updateStarRating() //Update the star rating view graphically
            }
        }
        //Get overall statistics
        //Set query to 'statistics' node
        let statsRef = db.collection("shows").document(show).collection(dateIndex).document("statistics")
        statsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot { //Validate that the returned document isn't empty
                self.statsDict = document.data()! //Assign the returned dictionary to a local variable
                self.updateAttributeLabels() //Update the labels in the view with the new values
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReviewsView"
        {
            let destinationVC = segue.destination as! ReviewsTableViewController
            destinationVC.show = show
            destinationVC.dateIndex = dateIndex
        }
    }
    
    

}
