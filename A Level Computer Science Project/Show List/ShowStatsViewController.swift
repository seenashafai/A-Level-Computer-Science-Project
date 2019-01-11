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

class ShowStatsViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!

    @IBOutlet weak var dateSegmentedView: UISegmentedControl!
    
    @IBAction func dateSegmentedViewAction(_ sender: Any) {
        refreshData()
    }
    //MARK: - Properties
    var db: Firestore!
    var show: Show?
    var blockDict: [String: Any] = [:]
    var blockDataEntries = [PieChartDataEntry]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        print(dateSegmentedView.selectedSegmentIndex, "selectedIndex")
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
            // Do any additional setup after loading the view.
        }
    }
    
    func retrieveRawData(show: String, dateIndex: String)
    {
       // var blockStatsDict: [String: Any] = [:]
        let userStatsRef = db.collection("shows").document(show).collection(dateIndex).document("userStats")
        userStatsRef.getDocument {(documentSnapshot, error) in
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
    }

}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}
