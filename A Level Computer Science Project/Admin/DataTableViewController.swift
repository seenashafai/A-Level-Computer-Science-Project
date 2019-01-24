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


class DataTableViewController: UIViewController {

    var dataTable: SwiftDataTable! = nil
    var user: User?
    var db: Firestore!
    var showDataArray = [[Any]]()
    var options = DataTableConfiguration()
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        db = Firestore.firestore()
        getData()
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "Show History"
        
        self.view.backgroundColor = UIColor.white
        
        options.shouldContentWidthScaleToFillFrame = false
        options.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        
       
    }
    func shouldAutorotate() -> Bool {
        return true
    }
    
    func arraySwap(array: [Any]) -> [Any]
    {
        var tempArray: [Any] = []
        var sortedArray: [Any] = []
        sortedArray = array

        //Name & Seats
        tempArray.append(array[0])
        sortedArray[6] = tempArray[0]
        
        return array
    }
    
    func getData()
    {
        var showData = [Any]()
        let numberOfShows = user?.ticketsBooked
        print(user?.showsBookedArray[0])
        for i in 0..<numberOfShows!
        {
            let showRef = db.collection("users").document((user?.email)!).collection("tickets").document((user?.showsBookedArray[i])!)
            showRef.getDocument { (document, error ) in
                if let document = document {
                    for (_, value) in document.data()! {
                        
                        showData.append("\(value)")
                    }
                    print(showData, "showDataItem")
                    print(self.showDataArray, "before")
                    showData = self.arraySwap(array: showData)
                    self.showDataArray.append(showData)
                    print(self.showDataArray, "after")
                    showData.removeAll()

                    if self.showDataArray.count == self.user?.ticketsBooked {
                        self.dataTable = SwiftDataTable(
                            data: self.data(),
                            headerTitles: self.columnHeaders(),
                            options: self.options
                        )
                    
                    self.dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
                    self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.dataTable.frame = self.view.frame
                    self.view.addSubview(self.dataTable);
                    }
                }
            }
        }
        print(showDataArray, "out")
        print(showData, "s2")

    }
}

extension DataTableViewController {
    func columnHeaders() -> [String] {
        return [
            "Name",
            "Date",
            "Attendance",
            "Seats",
            "TicketID",
            "dateIndex",
            "Tickets"
        ]
    }
    
    func data() -> [[DataTableValueType]]{
        //This would be your json object
        var dataSet: [[Any]] = self.showDataArray
        delayWithSeconds(1) {
        for _ in 0..<0 {
            print(self.showDataArray, "final2")
            dataSet += self.showDataArray
            }
            print(dataSet, "ds")
        }
        
        return dataSet.map {
            $0.compactMap (DataTableValueType.init)
        }
        
    }
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}
