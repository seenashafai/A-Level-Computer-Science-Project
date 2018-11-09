//
//  SecondarySeatSelectionViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 08/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class SecondarySeatSelectionViewController: UIViewController {

    @IBOutlet weak var cafeView: UIView!
    
    struct Table {
        let x: Int
        let y: Int
    }
    
    var tables = [
        Table(x: 2, y: 3), Table(x: 4, y: 3), Table(x: 6, y: 3),
        Table(x: 1, y: 5), Table(x: 3, y: 5), Table(x: 5, y: 5), Table(x: 7, y: 5),
        Table(x: 2, y: 7), Table(x: 4, y: 7), Table(x: 6, y: 7)]
    
    let cafeWidth = 8
    let cafeHeight = 10
    
    
    func viewForCoordinate(x: Int, y: Int, size: CGSize) -> UIView {
        let centerX = Int(cafeView.frame.size.width / CGFloat(cafeWidth)) * x
        let centerY = Int(cafeView.frame.size.height / CGFloat(cafeHeight)) * y
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.center = CGPoint(x: centerX, y: centerY)
        print(view.description, "viewDesc")
        return view
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cafeView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)

        // draw the grid
        for row in 1..<cafeHeight {
            for column in 1..<cafeWidth {
                let gridDot = viewForCoordinate(x: row, y: column, size: CGSize(width: 1, height: 1))
                gridDot.backgroundColor = UIColor.black
                cafeView.addSubview(gridDot)
                print("drawGrid")
            }
        }
        
        // draw the seats
        for table in tables {
            let tableView = viewForCoordinate(x: table.x, y: table.y, size: CGSize(width: 20, height: 20))
            tableView.layer.cornerRadius = 8
            tableView.backgroundColor = UIColor(hue: 100/360.0, saturation: 0.44, brightness: 0.33, alpha: 1)
            cafeView.addSubview(tableView)
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
