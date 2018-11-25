//
//  SecondarySeatSelectionViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 08/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class SecondarySeatSelectionViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var venueView: UIView!
    var mySubViews = [Int]()
    var selectedSeat: Int?

    
    struct Seat {
        let x: Int
        let y: Int
    }
    
    var seats = [Seat]()
    
    let venueWidth = 8
    let venueHeight = 10
    
    @IBOutlet weak var confirmBarButtonOutlet: UIBarButtonItem!
    @IBAction func confirmBarButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "toFinalConfirmation", sender: nil)
    }
    
    func viewForCoordinate(x: Int, y: Int, size: CGSize) -> UIView {
        let centerX = Int(venueView.frame.size.width / CGFloat(venueWidth)) * x
        let centerY = Int(venueView.frame.size.height / CGFloat(venueHeight)) * y
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.center = CGPoint(x: centerX, y: centerY)
        print(view.description, "viewDesc", view.tag)
        
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
            if width < 20
            {
                width = width + 2
            }
            if start > 0
            {
                start = start - 1
            }

        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmBarButtonOutlet.isEnabled = false
        venueView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        generateSeats()
        /* draw the grid
        for row in 1..<venueHeight {
            for column in 1..<venueWidth {
                let gridDot = viewForCoordinate(x: row, y: column, size: CGSize(width: 1, height: 1))
                gridDot.backgroundColor = UIColor.black
                venueView.addSubview(gridDot)
                print("drawGrid")
            }
        }
 */
 
        
        // draw the seats
        var index = 0
        for seat in seats {
            let seatView = viewForCoordinate(x: seat.x, y: seat.y, size: CGSize(width: 20, height: 20))
            seatView.layer.cornerRadius = 8
            seatView.backgroundColor = UIColor(hue: 100/360.0, saturation: 0.44, brightness: 0.33, alpha: 1)
            seatView.tag = index
            venueView.addSubview(seatView)
            print("drawTable")
            index = index + 1
        }
        

        for view in venueView.subviews {
            mySubViews.append(view.tag)
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getIndex(_:)))
            gestureRecognizer.view?.tag = index
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)

        }

    }
    
    
    @objc func getIndex(_ sender: UITapGestureRecognizer) {
        selectedSeat = mySubViews[(sender.view?.tag)!]
        print(selectedSeat)
        seatSelected(seatRef: selectedSeat!)
    }
    
    func seatSelected(seatRef: Int)
    {
        var seatView = venueView.viewWithTag(seatRef)
        if seatView?.backgroundColor == UIColor.orange
        {
            seatView?.backgroundColor = UIColor(hue: 100/360.0, saturation: 0.44, brightness: 0.33, alpha: 1)
        }
        else {
            seatView?.backgroundColor = UIColor.orange
        }
        confirmBarButtonOutlet.isEnabled = true
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
