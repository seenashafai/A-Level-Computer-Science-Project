//
//  DataTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 22/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

import SwiftDataTables

class DataTableViewController: UIViewController {

    //DateTables Variables
    var dataTable: SwiftDataTable! = nil
    var showDataArray = [[Any]]()
    var options = DataTableConfiguration()
    
    //Class instances
    var user: User?
    var db: Firestore!
    var show = showFunctions()
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        db = Firestore.firestore()
        getData()
        
        //UI features
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "Show attendance" //Set title of table
        
    }

    func getData()
    {
        var showData = [Any]() //Define sub-array
        let numberOfShows = user?.showAttendance.count //Get number of shows booked from attendance dictionary
        let showsBooked = Array((user?.showAttendance.keys)!) //Get names of booked shows from keys of attendance dictionary
        
        for i in 0..<numberOfShows! //Iterate through every show booked
        {
            //Define reference for each show booked
            let showRef = db.collection("users").document((user?.email)!).collection("tickets").document(showsBooked[i])
            showRef.getDocument { (document, error ) in //Get data from ticket booked for show
                if let document = document { //Validate that snapshot is retrived
                    let dict = document.data()! //Define retrieved dictionary
                    let date = dict["date"] as! Timestamp //Get date as timestamp
                    //Format date using external class
                    let formattedDate = self.show.timestampDateConverter(timestamp: date, format: "dd MMMM YYYY")
                    for _ in dict { //Iterate through resulting dictionary
                
                        //Assign values to sub-array
                        showData.append(dict["show"]!)
                        showData.append(formattedDate)
                        showData.append(self.convertBool(value: dict["attendance"]! as! Int))
                        showData.append(dict["seats"]!)
                        showData.append(dict["tickets"]!)

                    }
                    //Add sub-aray to main array
                    self.showDataArray.append(showData)
                    showData.removeAll() //Empty sub-array for next batch of values

                    //Set headers and configuration (Framework specific)
                    if self.showDataArray.count == numberOfShows {
                        self.dataTable = SwiftDataTable(
                            data: self.data(),
                            headerTitles: self.columnHeaders(),
                            options: self.options
                        )
                    //More UI features
                    self.dataTable.frame = self.view.frame
                    self.view.addSubview(self.dataTable);
                    }
                }
            }
        }

    }
    
    //Convert number boolean stored in Firestore into True/False string
    func convertBool(value: Int) -> String
    {
        switch value {
        case 0:
            return "False"
        case 1:
            return "True"
        default:
            return "n/a"
        }
    }
}

//Set column headers for table
extension DataTableViewController {
    func columnHeaders() -> [String] {
        return [
            "Name",
            "Date",
            "Attendance",
            "Seats",
            "Tickets",
        ]
    }
    
    //Assign data to table
    func data() -> [[DataTableValueType]]{
        return showDataArray.map { //Convert 2D array into readable data for spreadsheet
            $0.compactMap (DataTableValueType.init)
        }
    }
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}
