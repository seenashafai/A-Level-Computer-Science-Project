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

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var dateSegmentedView: UISegmentedControl!
    
    @IBOutlet weak var ticketHoldersLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var missingLabel: UILabel!
    @IBOutlet weak var pctTurnoutLabel: UILabel!
    @IBOutlet weak var topHousesLabel: UILabel!
    @IBOutlet weak var unclaimedTicketsLabel: UILabel!
    
    
    
    
    @IBAction func dateSegmentedViewAction(_ sender: Any) {
        retrieveRawData(show: (show?.name)!, dateIndex: String(dateSegmentedView!.selectedSegmentIndex + 1))
    }
    //MARK: - Properties
    var db: Firestore!
    var show: Show?
    var blockDict: [String: Any] = [:]
    var blockDataEntries = [PieChartDataEntry]()
    var starRatingsArray: [Double] = []
    var statsDict: [String: Any] = [:]
    var houseDict: [String: Int] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        retrieveRawData(show: (show?.name)!, dateIndex: String(dateSegmentedView!.selectedSegmentIndex + 1))
        print(dateSegmentedView.selectedSegmentIndex, "selectedIndex")
        cosmosView.isUserInteractionEnabled = false
        
    }
    
    

    func updateChart()
    {
        let blockDataB = PieChartDataEntry(value: self.blockDict["B"] as! Double, label: "B")
        let blockDataC = PieChartDataEntry(value: self.blockDict["C"] as! Double, label: "C")
        let blockDataD = PieChartDataEntry(value: self.blockDict["D"] as! Double, label: "D")
        let blockDataE = PieChartDataEntry(value: self.blockDict["E"] as! Double, label: "E")
        let blockDataF = PieChartDataEntry(value: self.blockDict["F"] as! Double, label: "F")
        self.blockDataEntries = [blockDataB, blockDataC, blockDataD, blockDataE, blockDataF]
        
        let chartDataSet = PieChartDataSet(values: blockDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let colours = [UIColor.blue, UIColor.red, UIColor.green, UIColor.orange, UIColor.gray]
        chartDataSet.colors = colours
        
        pieChartView.data = chartData
    }
    
    func updateStarRating()
    {
        let count = self.starRatingsArray.count
        var totalStars: Double = 0
        print(self.starRatingsArray, "sta")
        for star in self.starRatingsArray {
            totalStars += star
        }
        let avgStarRating = totalStars/Double(count)
        print(avgStarRating, "asr")
        self.cosmosView.rating = Double(avgStarRating)
    }
    
    func updateAttributeLabels()
    {
        let ticketHolders = (self.statsDict["numberOfTicketHolders"] as! Int)
        self.ticketHoldersLabel.text = String(ticketHolders)
        let unclaimedTickets = self.statsDict["availableTickets"] as! Int
        self.unclaimedTicketsLabel.text = String(unclaimedTickets)
        let attendees = (self.statsDict["attendees"] as! Int)
        self.attendeesLabel.text = String(attendees)
        self.missingLabel.text = String(ticketHolders - attendees)
        let pctTurnout = (Float(attendees)/Float(ticketHolders) * 100)
        self.pctTurnoutLabel.text = (String(pctTurnout) + "%")
    }
    
    func updateHouseList()
    {
        let sortedHouseDict = self.houseDict.sorted(by: {$0.value > $1.value} )
        print(sortedHouseDict, "sorted")
        var top5HouseArray: [String] = []
        for i in 0..<5
        {
            if sortedHouseDict[i].value > 0
            {
                top5HouseArray.append(sortedHouseDict[i].key)
            }
        }
        print(top5HouseArray)
        self.topHousesLabel.text = top5HouseArray.description
    }

    
    func retrieveRawData(show: String, dateIndex: String)
    {
        blockDict.removeAll()
        houseDict.removeAll()
        starRatingsArray.removeAll()
        
       // var blockStatsDict: [String: Any] = [:]
        let blockStatsRef = db.collection("shows").document(show).collection(dateIndex).document("blockStats")
        print(dateIndex, "dI")
        blockStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.blockDict = document.data()!
                self.updateChart()
            }
        }
        
        let houseStatsRef = db.collection("shows").document(show).collection(dateIndex).document("houseStats")
        houseStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.houseDict = document.data()! as! [String : Int]
                self.updateHouseList()
            }
        }
        
        let totalRatingsRef = db.collection("shows").document(show).collection(dateIndex).document("reviews")
        totalRatingsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                print(document, "soc")
                self.starRatingsArray = (document["starRating"] as? Array ?? [0.0])
                self.updateStarRating()
            }
        }
        
        let statsRef = db.collection("shows").document(show).collection(dateIndex).document("statistics")
        statsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.statsDict = document.data()!
                self.updateAttributeLabels()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReviewsView"
        {
            let destinationVC = segue.destination as! ReviewsTableViewController
            destinationVC.show = show
        }
    }
    
    

}
