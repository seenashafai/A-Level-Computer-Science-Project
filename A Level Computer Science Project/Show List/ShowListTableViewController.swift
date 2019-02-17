//
//  ShowListTableViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 17/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class ShowListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var showArray = ["Othello", "Macbeth", "Twelfth Night", "Romeo & Juliet"]

    //MARK: - Interface Outlets
    @IBOutlet weak var tableView: UITableView!

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    // MARK: - TableView Delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //Number of sections in TableView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showArray.count //Number of rows, from number of elements in array
    }
    
    //MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Define custom cell with a reusable identifier so it can be repeated across the tableView
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowListTableViewCell
        //Above: assigning custom cell type 'ShowListTableViewCell' to the cell definition
        
        cell.cellNameLabel.text = showArray[indexPath.row] //Define show name, from show array and cell c=index
        cell.cellDescriptionLabel.text = "December 3rd - 5th" //Define date text
        cell.cellImageView.image = nil //Define image location
        
        return cell
    }
}
