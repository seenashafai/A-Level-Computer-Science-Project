//
//  SecondarySeatSelectionViewController.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 08/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class SecondarySeatSelectionViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var venueView: UIView!
    
    //MARK: - Classes
    var user = FirebaseUser()
    var db: Firestore!
    var ticket: Ticket?

    var fullArray: [Int]?

    
    var mySubViews = [Int]()
    var selectedSeat: Int?
    var listener: ListenerRegistration!
    var currentUser: [String: Any] = [:]
    var transactionDict: [String: Any] = [:]

    var allocatedSeats: Int?
    var remainingSeats: Int?
    var dateIndex: Int!
    var showName: String!
    var date: Timestamp!
    var transactionID: Int?
    var house: String?
    var block: String?

    @IBOutlet weak var remainingSeatsLabel: UILabel!
    @IBOutlet weak var totalSeatsLabel: UILabel!
    
    //Initialise Seat structure
    struct Seat {
        let x: Int
        let y: Int
    }
    
    var seats = [Seat]() //Initialise array of Seat objects
    
    let venueWidth = 30
    let venueHeight = 12
    
    @IBOutlet weak var confirmBarButtonOutlet: UIBarButtonItem!
    @IBAction func confirmBarButtonAction(_ sender: Any) {
        
        //Define database location for seating chart
        let statsRef = db.collection("shows").document(showName).collection(String(dateIndex)).document("statistics")
        statsRef.updateData([ //Update data in reference location
            "availableSeats": compareSeats(),
        ])  { err in //CLOSURE: error handling
            if err != nil { //If the error is not nil
                print(err?.localizedDescription) //Output API error
            } else //If error object is empty (i.e. there is no error)
            {
                print("success") //Trace output
                //Transition to next view
                self.performSegue(withIdentifier: "toTicketSummary", sender: nil)
            }
        }
        
        
        house = currentUser["house"] as! String
        block = currentUser["block"] as! String

        print(currentUser.debugDescription, "debug")
        print(house, "currentUserHouse")
        var transactionRef = db.collection("transactions").document("currentTransaction")
        transactionRef.setData(transactionDict)
    }

    
    
    func getTransactionID()
    {
        let transactionRef = db.collection("properties").document("transactions")
        transactionRef.getDocument {(documentSnapshot, error) in
            if let error = error
            {
                print(error.localizedDescription, "transaction retrieval error")
                return
            }
            if let document = documentSnapshot {
                self.transactionID = document.data()!["runningTotal"] as! Int
                }
            }

        }
    
    func viewForCoordinate(x: Int, y: Int, size: CGSize) -> UIView {
        let centerX = Int(venueView.frame.size.width / CGFloat(venueWidth)) * x
        let centerY = Int(venueView.frame.size.height / CGFloat(venueHeight)) * y
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.center = CGPoint(x: centerX, y: centerY)
        print(view.description, "viewDesc", view.tag)
        
        return view
    }

    
    func updateSeatsArray() -> [Int]
    {
        var indicesToRemove = [Int]() //Initialise new array to hold indices being removed
        for i in 0..<fullArray!.count //Iterate through database array
        {
            for j in 0..<picked.count //Iterate through array of picked seats
            {
                indicesToRemove.append(i) //Add index of picked seat to new array
                print(fullArray![i], "toRemove") //Output this value for debugging
            }
        }
        var array = fullArray! //Define new array instead of modifying the original array
        var shiftIndex = 0 //Initialise shift index to counteract the shifting of the array items when removal occurs
        for i in 0..<indicesToRemove.count //Iterate through the array of items which need removal
        {
            //Apply shift index to removal index to counteract the shifting of all items down as items are removed
            array.remove(at: indicesToRemove[i - shiftIndex]) //Remove items using indices in removal array
            shiftIndex = shiftIndex + 1 //Increment the shift index every time an item is removed
        }
        return array
    }
    
    func compareSeats() -> [Int]
    {
        let seatsArray = fullArray!.filter { !picked.contains($0) }
        return seatsArray
    }
    
    
    func generateSeats() {
        let numberOfRows: Int = 10
        var width: Int = 10
        var startPosition: Int = 10
        for y in 0..<numberOfRows
        {
            for x in 0..<width
            {
                seats.append(Seat(x: x + startPosition, y: y + 1))
            }
            startPosition = startPosition - 1
            width = width + 2
        }
        print(seats, "seats")
        createVenue()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        fullArray = ticket?.availableSeats
        getTransactionID()
        confirmBarButtonOutlet.isEnabled = false
        venueView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        totalSeatsLabel.text = allocatedSeats?.description
        remainingSeats = allocatedSeats
        remainingSeatsLabel.text = allocatedSeats?.description
        generateSeats()

        
       
    }
    
    func createVenue()
    {
        // draw the seats
        var index = 1 //Define index of each seat UPDATE: starts at 1 rather than 0
        
        for seat in seats //Loop through each seat in the seats array
        {
            //Define each seat position
            let seatView = viewForCoordinate(x: seat.x, y: seat.y, size: CGSize(width: 20, height: 20))
            seatView.layer.cornerRadius = 8
            seatView.tag = index
            
            if isSeatReserved(seat: seatView)
            {
                seatView.backgroundColor = UIColor.gray
                seatView.isUserInteractionEnabled = false
            }
            else
            {
                seatView.backgroundColor = UIColor(hue: 100/360.0, saturation: 0.44, brightness: 0.33, alpha: 1)
            }
            venueView.addSubview(seatView)
            index = index + 1
            
    }
        
        for view in venueView.subviews { //Iterate through subviews
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getIndex(_:))) //Define gesture recogniser
            gestureRecognizer.view?.tag = index //Set tag of GR
            mySubViews.append(view.tag) //Add seat's tag to array
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer) //Add GR to seat
        }
    }
    
    
    
    @objc func getIndex(_ sender: UITapGestureRecognizer) {
        selectedSeat = mySubViews[((sender.view?.tag)! - 1)] //Cross reference seat tag and GR tag
        //Subtract 1 from the tag, as now the seats begin indexing at 1 rather than 0
        print(selectedSeat) //Output selected seat for debugging
        seatSelected(seatRef: selectedSeat!) //Pass selected seat reference to the seatSelected function
    }
    //Checks if seat is reserved, returns boolean
    func isSeatReserved(seat: UIView) -> Bool //Take in seat from loop as parameter
    {
        print(fullArray, "full")
        //Iterate through seats pulled from database
        for i in 0..<((fullArray?.count)! - 1) {
            print(seat.tag, "tg")
            //Check if seat is present in array
            if seat.tag == fullArray![i]
            {
                print("available", seat.tag)
                return false //Seat is available
            }
        }
        return true //Default case
    }
    
    var picked = [Int]()
    
    func seatSelected(seatRef: Int)
    {
        var seatView = venueView.viewWithTag(seatRef)
        //Validation - if seat is already selected
        if seatView?.backgroundColor == UIColor.orange
        {   //Set colour of seat back to green
            seatView?.backgroundColor = UIColor(hue: 100/360.0, saturation: 0.44, brightness: 0.33, alpha: 1)
            let seatArrayIndex = picked.firstIndex(of: seatRef)
            picked.remove(at: seatArrayIndex!)
            remainingSeats = remainingSeats! + 1
            remainingSeatsLabel.text = remainingSeats?.description
        }
        else { //If seat is not already selected
            if picked.count == allocatedSeats
            {
                //Already selected the maximum number of seats
                confirmBarButtonOutlet.isEnabled = true
            }
            else { //If the user is able to select new seats
                seatView?.backgroundColor = UIColor.orange //Set colour
                picked.append(selectedSeat!) //Add seat number to array
                remainingSeats = remainingSeats! - 1 //Reduce the number of seats allocated
                remainingSeatsLabel.text = remainingSeats?.description //Output number of seats allocated remaining
            }
        }
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTicketSummary" //Identify next view
        {
            //Instantiate succeeding class
            let dest = segue.destination as! TicketConfirmationViewController
            //Assign data to succeeding class
            dest.date = date
            dest.email = user.getCurrentUserEmail()
            dest.seats = picked.description
            dest.tickets = String(allocatedSeats!)
            dest.show = showName
            dest.dateIndex = dateIndex
        }
    }
 

}
