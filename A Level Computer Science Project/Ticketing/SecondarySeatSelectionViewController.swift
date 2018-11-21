//
//  SecondarySeatSelectionViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 08/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class SecondarySeatSelectionViewController: UIViewController {

    @IBOutlet weak var venueView: UIView!
    
    struct Seat {
        let x: Int
        let y: Int
    }
    
    var seats = [Seat]()
    
    let venueWidth = 8
    let venueHeight = 10
    
    
    func viewForCoordinate(x: Int, y: Int, size: CGSize) -> UIView {
        let centerX = Int(venueView.frame.size.width / CGFloat(venueWidth)) * x
        let centerY = Int(venueView.frame.size.height / CGFloat(venueHeight)) * y
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.center = CGPoint(x: centerX, y: centerY)
        print(view.description, "viewDesc")
        return view
    }
    
    func generateSeats() {
        var width: Int = 10
        var start: Int = 5
        for j in 0..<10
        {
            for i in 0..<width
            {
                seats.append(Seat(x: i + start, y: j))
            }
            width = width + 1
            if start > 0
            {
                start = start - 1
            }

        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venueView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        generateSeats()
        // draw the grid
        for row in 1..<venueHeight {
            for column in 1..<venueWidth {
                let gridDot = viewForCoordinate(x: row, y: column, size: CGSize(width: 1, height: 1))
                gridDot.backgroundColor = UIColor.black
                venueView.addSubview(gridDot)
                print("drawGrid")
            }
        }
        
        // draw the seats
        for table in seats {
            let tableView = viewForCoordinate(x: table.x, y: table.y, size: CGSize(width: 20, height: 20))
            tableView.layer.cornerRadius = 8
            tableView.backgroundColor = UIColor(hue: 100/360.0, saturation: 0.44, brightness: 0.33, alpha: 1)
            venueView.addSubview(tableView)
            print("drawTable")
        }
        


        // Do any additional setup after loading the view.
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
