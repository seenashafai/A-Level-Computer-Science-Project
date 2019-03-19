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
    var ticket = Ticker?


    
    var mySubViews = [Int]()
    var selectedSeat: Int?
    var listener: ListenerRegistration!
    var currentUser: [String: Any] = [:]
    var transactionDict: [String: Any] = [:]

    var allocatedSeats: Int?
    var remainingSeats: Int?
    var dateIndex: Int!
    var showName: String!
    var seatsArray: [Int]?
    var date: String!
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
    
    let venueWidth = 11
    let venueHeight = 11
    
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
        

        
        transactionDict = [
            "transactionID": transactionID,
            "email": user.getCurrentUserEmail(),
            "show": showName,
            "tickets": allocatedSeats,
            "seats": picked,
            "date": date,
            "house": house,
            "block": block
        ]
        
        pushToFirestore(dateIndex: String(dateIndex))
        pushToFirestore(dateIndex: "4")
        
        print(currentUser.debugDescription, "debug")
        print(house, "currentUserHouse")
        var transactionRef = db.collection("transactions").document("currentTransaction")
        transactionRef.setData(transactionDict)
    }

    func pushToFirestore(dateIndex: String)
    {
        let blockStatsRef = db.collection("shows").document(showName).collection(String(dateIndex)).document("blockStats")
        let currentBlock = block!
        var currentBlockStat: Int = 0
        blockStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                print(document.data(), "document")
                currentBlockStat = document.data()![currentBlock] as! Int
                
                blockStatsRef.updateData([
                    self.block: currentBlockStat + 1
                    ])
            }
        }
        
        let houseStatsRef = db.collection("shows").document(showName).collection(String(dateIndex)).document("houseStats")
        let currentHouse = house!
        var currentHouseStat: Int = 0
        houseStatsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                print(document.data(), "document")
                currentHouseStat = document.data()![currentHouse] as! Int
                
                houseStatsRef.updateData([
                    self.house: currentHouseStat + 1,
                    ])

            }
        }
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
        for i in 0..<fullArray.count //Iterate through database array
        {
            for j in 0..<picked.count //Iterate through array of picked seats
            {
                indicesToRemove.append(i) //Add index of picked seat to new array
                print(fullArray[i], "toRemove") //Output this value for debugging
            }
        }
        var array = fullArray //Define new array instead of modifying the original array
        var shiftIndex = 0 //Initialise shift index to counteract the shifting of the array items when removal occurs
        for i in 0..<indicesToRemove.count //Iterate through the array of items which need removal
        {
            //Apply shift index to removal index to counteract the shifting of all items down as items are removed
            array.remove(at: indicesToRemove[i - shiftIndex]) //Remove items using indices in removal array
            shiftIndex = shiftIndex + 1 //Increment the shift index every time an item is removed
        }
        return array
    }
    
    
    func generateSeats() {
        let numberOfRows: Int = 10
        var width: Int = 10
        var startPosition: Int = 10
        for y in 0..<numberOfRows
        {
            for x in 0..<width
            {
                seats.append(Seat(x: x + startPosition, y: y + 10))
            }
            startPosition = startPosition + 1
            width = width + 2
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getTransactionID()
        confirmBarButtonOutlet.isEnabled = false
        venueView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        generateSeats()
        totalSeatsLabel.text = allocatedSeats?.description
        remainingSeats = allocatedSeats
        remainingSeatsLabel.text = allocatedSeats?.description
        
       
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let query = db.collection("shows").document(showName).collection(String(dateIndex))
        self.listener =  query.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Ticket in
                if let ticket = Ticket(dictionary: document.data()) {
                    print(document.data(), "docData")
                    return ticket
                } else {
                    fatalError("Unable to initialize type \(Ticket.self) with dictionary \(document.data())")
                }
            }
            
            self.ticket = results[0]
            self.seatsArray = self.ticket.availableSeats

        }
        
        delayWithSeconds(0.2)
        {
            self.createVenue()
        }

    }

    
    
    func createVenue()
    {
        // draw the seats
        var index = 1
        for seat in seats
        {
            let seatView = viewForCoordinate(x: seat.x, y: seat.y, size: CGSize(width: 20, height: 20))
            seatView.layer.cornerRadius = 8
            seatView.tag = index
            print(seatView.tag, "tag")
            print(seatsArray, "seats")
            guard seatsArray?.count != nil else {print("Seats not set up in Database"); return}
            if (seatsArray?.contains(seatView.tag))!
            {
                seatView.backgroundColor = UIColor(hue: 100/360.0, saturation: 0.44, brightness: 0.33, alpha: 1)
                print("el samo")
                seatView.isUserInteractionEnabled = true
            }
            else
            {
                seatView.backgroundColor = UIColor.gray
                seatView.isUserInteractionEnabled = false
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
        selectedSeat = mySubViews[((sender.view?.tag)! - 1)]
        print(selectedSeat)
        seatSelected(seatRef: selectedSeat!)
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
        if segue.identifier == "toFinalConfirmation"
        {
            let destinationVC = segue.destination as! TicketConfirmationViewController
            destinationVC.dateIndex = dateIndex
        }
    }
 

}
