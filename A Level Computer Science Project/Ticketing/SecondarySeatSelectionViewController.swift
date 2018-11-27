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

    var allocatedSeats: Int?
    var remainingSeats: Int?
    var dateIndex: Int!
    var showName: String!
    var seatsArray: [Int]!
    var date: String!
    var house: String!

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
            "numberOfTicketHolders": ticket[0].numberOfTicketHolders,
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
        
        var transactionRef = db.collection("transactions")
        transactionRef.addDocument(data: [
            "email": user.getCurrentUserEmail(),
            "show": showName,
            "tickets": allocatedSeats,
            "seats": picked,
            "date": date,
            "house": house
            ])
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
            for i in 0..<seatsArray.count
            {
                print(seatsArray[i], "seatspicked")
                print(picked[seat], "pickedseat")
                if picked[seat] == seatsArray[i]
                {
                    seatsArray.remove(at: seat)
                    print("removed", seatsArray[i])
                }
            }
            print(seatsArray, "withRemoved")
        }
        return seatsArray!
    }
    
    func compareSeats() -> [Int]
    {
        
        seatsArray = seatsArray.filter { !picked.contains($0) }
        print(seatsArray, "withNewRemoved")
        return seatsArray
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
        db = Firestore.firestore()
        self.query = baseQuery()
        confirmBarButtonOutlet.isEnabled = false
        venueView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        generateSeats()
        totalSeatsLabel.text = allocatedSeats?.description
        remainingSeats = allocatedSeats
        remainingSeatsLabel.text = allocatedSeats?.description
        
       
    }
    
    
    //MARK: - Firebase Query methods
    
    fileprivate func baseQuery() -> Query{
        return db.collection("shows").document(showName).collection(String(dateIndex))
    }
    fileprivate var query: Query? {
        didSet {
            if let listener = listener{
                listener.remove()
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
        
        
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Ticket in
                if let ticket = Ticket(dictionary: document.data()) {
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
            if seatsArray.contains(seatView.tag)
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
        
        
        for view in venueView.subviews {
            mySubViews.append(view.tag)
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getIndex(_:)))
            gestureRecognizer.view?.tag = index
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            
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
                seatView?.backgroundColor = UIColor.orange
                picked.append(selectedSeat!)
                print(picked)
                print(remainingSeats, "remaining")
                remainingSeats = remainingSeats! - 1
                remainingSeatsLabel.text = remainingSeats?.description
                if picked.count == allocatedSeats
                {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
