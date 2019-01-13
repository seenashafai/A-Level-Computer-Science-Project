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
        refreshData()
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
        print(dateSegmentedView.selectedSegmentIndex, "selectedIndex")
        cosmosView.isUserInteractionEnabled = false
        refreshData()
        
    }
    
    

    func updateChart()
    {
        let chartDataSet = PieChartDataSet(values: blockDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let colours = [UIColor.blue, UIColor.red, UIColor.green, UIColor.orange, UIColor.gray]
        chartDataSet.colors = colours
        
        pieChartView.data = chartData
    }
    
    func refreshData()
    {
        let name = show?.name
        print(name, "showName")
        retrieveRawData(show: (show?.name)!, dateIndex: String(dateSegmentedView!.selectedSegmentIndex + 1))
        delayWithSeconds(1) {
            let blockDataB = PieChartDataEntry(value: self.blockDict["B"] as! Double, label: "B")
            let blockDataC = PieChartDataEntry(value: self.blockDict["C"] as! Double, label: "C")
            let blockDataD = PieChartDataEntry(value: self.blockDict["D"] as! Double, label: "D")
            let blockDataE = PieChartDataEntry(value: self.blockDict["E"] as! Double, label: "E")
            let blockDataF = PieChartDataEntry(value: self.blockDict["F"] as! Double, label: "F")
            self.blockDataEntries = [blockDataB, blockDataC, blockDataD, blockDataE, blockDataF]
            self.updateChart()
            
            let count = self.starRatingsArray.count
            var totalStars: Double = 0
            
            for star in self.starRatingsArray {
                totalStars += star
            }
            let avgStarRating = totalStars/Double(count)
            self.cosmosView.rating = Double(avgStarRating)
            
            let ticketHolders = Float(self.statsDict["numberOfTicketHolders"] as! Int)
            self.ticketHoldersLabel.text = String(ticketHolders)
            let unclaimedTickets = self.statsDict["availableTickets"] as! Int
            self.unclaimedTicketsLabel.text = String(unclaimedTickets)
            let attendees = Float(self.statsDict["attendees"] as! Int)
            self.attendeesLabel.text = String(attendees)
            self.missingLabel.text = String(ticketHolders - attendees)
            let pctTurnout = (attendees/ticketHolders * 100)
            self.pctTurnoutLabel.text = (String(pctTurnout) + "%")
            
            
            let sortedHouseDict = self.houseDict.sorted(by: {$0.value < $1.value} )
            var top5HouseArray: [String] = [""]
            for i in 0..<6
            {
                top5HouseArray.append(sortedHouseDict[i].key)
            }
            self.topHousesLabel.text = top5HouseArray.description
        }
    }
    
    func retrieveRawData(show: String, dateIndex: String)
    {
       // var blockStatsDict: [String: Any] = [:]
        let blockStatsRef = db.collection("shows").document(show).collection(dateIndex).document("blockStats")
        blockStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                let b = document.data()!["B"]
                let c = document.data()!["C"]
                let d = document.data()!["D"]
                let e = document.data()!["E"]
                let f = document.data()!["F"]
                self.blockDict = [
                    "B": b as Any,
                    "C": c as Any,
                    "D": d as Any,
                    "E": e as Any,
                    "F": f as Any
                ]
            }
        }
        
        let houseStatsRef = db.collection("shows").document(show).collection(dateIndex).document("houseStats")
        houseStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.houseDict = document.data()! as! [String : Int]
            }
        }
        
        let totalRatingsRef = db.collection("shows").document(show).collection(dateIndex).document("reviews")
        totalRatingsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.starRatingsArray = document["starRatingsArray"] as? Array ?? [0]
            }
        }
        
        let statsRef = db.collection("shows").document(show).collection(dateIndex).document("statistics")
        statsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                self.statsDict = document.data()!
            }
        }
    }

    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }

}
