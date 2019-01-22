//
//  DataTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 22/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import SwiftDataTables


class DataTableViewController: UIViewController {

    var dataTable: SwiftDataTable! = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "Employee Balances"
        
        self.view.backgroundColor = UIColor.white
        
        var options = DataTableConfiguration()
        options.shouldContentWidthScaleToFillFrame = false
        options.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)
        
        self.dataTable = SwiftDataTable(
            data: self.data(),
            headerTitles: self.columnHeaders(),
            options: options
        )
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataTable.frame = self.view.frame
        self.view.addSubview(self.dataTable);
    }
}

extension DataTableViewController {
    func columnHeaders() -> [String] {
        return [
            "Id",
            "Name",
            "Email",
            "Number",
            "City",
            "Balance"
        ]
    }
    
    func data() -> [[DataTableValueType]]{
        //This would be your json object
        var dataSet: [[Any]] = exampleDataSet()
        for _ in 0..<0 {
            dataSet += exampleDataSet()
        }
        
        return dataSet.map {
            $0.compactMap (DataTableValueType.init)
        }
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
