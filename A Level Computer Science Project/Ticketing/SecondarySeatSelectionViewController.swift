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
    
    var mySubViews = [Int]()
    var selectedSeat: Int?
    var db: Firestore!
    var user = FirebaseUser()
    var documents: [DocumentSnapshot] = []
    var listener: ListenerRegistration!
    var ticket = [Ticket]()
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
    
    struct Seat {
        let x: Int
        let y: Int
    }
    
    var seats = [Seat]()
    
    let venueWidth = 11
    let venueHeight = 11
    
    @IBOutlet weak var confirmBarButtonOutlet: UIBarButtonItem!
    @IBAction func confirmBarButtonAction(_ sender: Any) {
        
        
        let statsRef = db.collection("shows").document(showName).collection(String(dateIndex)).document("statistics")
        print(user.getCurrentUserEmail(), "currentUserEmail")
        statsRef.updateData([
            "availableSeats": compareSeats(),
            "availableTickets": ticket[0].availableTickets,
            "ticketHolders": FieldValue.arrayUnion([user.getCurrentUserEmail()])
        ])  { err in
            if err != nil {
                print("errorino", err?.localizedDescription)
            } else
            {
                print("success/dome")
                self.performSegue(withIdentifier: "toFinalConfirmation", sender: nil)
            }
        }

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
        
        //Push statistics to database
        pushToFirestore(dateIndex: String(dateIndex)) //Specified date index
        pushToFirestore(dateIndex: "4") //Total dateIndex

        print(currentUser.debugDescription, "debug")
        print(house, "currentUserHouse")
        var transactionRef = db.collection("transactions").document("currentTransaction")
        transactionRef.setData(transactionDict)
    }

    func pushToFirestore(dateIndex: String)
    {
        //Input date index and create database reference for block statistics
        let blockStatsRef = db.collection("shows").document(showName).collection(dateIndex).document("blockStats")
        let currentBlock = currentUser["block"] as! String //Retrieve user's block from dictionary
        var currentBlockStat: Int? //Initialise empty block statistic to be filled by database
        blockStatsRef.getDocument {(documentSnapshot, error) in //Retrieve database dictionary of all blocks
            if let document = documentSnapshot { //Validate pulled dictionary to ensure it is not empty
                currentBlockStat = document.data()![currentBlock] as? Int //Pull block statistic from dictionary and assign it locally
                
                //Increment block stat
                blockStatsRef.updateData([
                    currentBlock: currentBlockStat! + 1
                    ])
            }
        }
        //Input date index and create database reference for house statistics
        let houseStatsRef = db.collection("shows").document(showName).collection(dateIndex).document("houseStats")
        let currentHouse = currentUser["house"] as! String//Retrieve user's house from dictionary
        var currentHouseStat: Int? //Initialise empty house statistic to be filled from database
        houseStatsRef.getDocument {(documentSnapshot, error) in //Retrieve database dictionary of all houses
            if let document = documentSnapshot { //Validate pulled dictionary to ensure it is not empty
                currentHouseStat = document.data()![currentHouse] as? Int //Pull house statistic from dictionary and assign it locally
                
                //Upload incremented house stat
                houseStatsRef.updateData([
                    currentHouse: currentHouseStat! + 1,
                    ])
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
    
    func seatsTaken() -> [Int]
    {
        print(picked, "picked")
        for seat in 0..<picked.count
        {
            for i in 0..<seatsArray!.count
            {
                print(seatsArray?[i], "seatspicked")
                print(picked[seat], "pickedseat")
                if picked[seat] == seatsArray?[i]
                {
                    seatsArray!.remove(at: seat)
                    print("removed", seatsArray?[i])
                }
            }
            print(seatsArray, "withRemoved")
        }
        return seatsArray!
    }
    
    func compareSeats() -> [Int]
    {
        
        seatsArray = seatsArray!.filter { !picked.contains($0) }
        print(seatsArray, "withNewRemoved")
        return seatsArray!
    }
    
    func generateSeats() {
        var width: Int = 10
        var start: Int = 1
        for j in 0..<10
        {
            for i in 0..<width
            {
                seats.append(Seat(x: i + start, y: j + start))
            }
            /*
            if width < 20
            {
                width = width + 2
            }
            if start > 0
            {
                start = start - 1
            }
        */
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore() //Initialise database in class
        pullUserInformation() //Retrieve information from database
        
        confirmBarButtonOutlet.isEnabled = false
        venueView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        generateSeats()
        totalSeatsLabel.text = allocatedSeats?.description
        remainingSeats = allocatedSeats
        remainingSeatsLabel.text = allocatedSeats?.description
    }
    
    
    //MARK: - Firebase Query methods
    
    //Retrieve dictionary of user information
    func pullUserInformation() {
        let userEmail = user.getCurrentUserEmail() //Get user email
        let userRef = db.collection("users").document(userEmail) //Create reference for user's location in db
        userRef.getDocument {(documentSnapshot, error) in //Retrieve data from database reference
            if let document = documentSnapshot { //Validate data to make sure it is not nil
                self.currentUser = (document.data() ?? nil)! //Assign data as local dictionary
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
        print("listener removed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let query = db.collection("shows").document(showName).collection(String(dateIndex)).whereField("availableTickets", isGreaterThanOrEqualTo: 0)
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
            
            self.ticket = results
            self.seatsArray = self.ticket[0].availableSeats
            self.documents = snapshot.documents
            print(self.ticket, "selfTicket")
            print(self.seatsArray, "selfSeatsArray")
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
        if seatView?.backgroundColor == UIColor.orange
        {
            seatView?.backgroundColor = UIColor(hue: 100/360.0, saturation: 0.44, brightness: 0.33, alpha: 1)
            confirmBarButtonOutlet.isEnabled = false
            for i in 0..<picked.count
            {
                if picked[i] == selectedSeat
                {
                    picked.remove(at: i)
                    remainingSeats = remainingSeats! + 1
                    remainingSeatsLabel.text = remainingSeats?.description
                }
            }
            print(picked)
        }
        else {
            if picked.count == allocatedSeats
            {
                print("no")
                confirmBarButtonOutlet.isEnabled = true
            }
            else {
                seatView?.backgroundColor = UIColor.orange //Set colour
                picked.append(selectedSeat!) //Add seat number to array
                remainingSeats = remainingSeats! - 1 //Reduce the number of seats allocated
                remainingSeatsLabel.text = remainingSeats?.description //Output number of seats allocated remaining
                if picked.count == allocatedSeats //If all seats allocated have been selected
                {
                    //Enable the user to continue to the next view
                    confirmBarButtonOutlet.isEnabled = true
                }

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
            destinationVC.show = showName
            destinationVC.date = date
            destinationVC.seats = picked.description
            destinationVC.email = user.getCurrentUserEmail()
            destinationVC.tickets = String(allocatedSeats!)
            
            
        }
    }
 

}
