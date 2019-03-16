//
//  UserTicket.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 10/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import Foundation
import Firebase

struct UserTicket {
    
    //Define variables
    var attendance: Bool = false
    var ticketID: Int = 0
    var date: Timestamp?
    var seats: String = ""
    var show: String = ""
    var tickets: String = ""
    var dateIndex: Int = 0 //1: Thursday, 2: Friday, 3: Saturday
    
    //Initialise dictionary method...
    var dictionary: [String: Any] {
        return [
            "ticketID": ticketID,
            "attendance": attendance,
            "date": date,
            "seats": seats,
            "show": show,
            "tickets": tickets,
            "dateIndex": dateIndex
        ]
    }
}


extension UserTicket { //Extension to the dictionary method to initialise it from a query response
    init?(dictionary: [String: Any]) {
        //Assign database values into a dictionary
        guard let attendance = dictionary["attendance"] as? Bool,
            let date = dictionary["date"] as? Timestamp,
            let ticketID = dictionary["ticketID"] as? Int,
            let seats = dictionary["seats"] as? String,
            let show = dictionary["show"] as? String,
            let tickets = dictionary["tickets"] as? String,
            let dateIndex = dictionary["dateIndex"] as? Int

            else {return nil}
        
        //Initialise this extension by adding the responses into the original dictionary in the main class body
        self.init(attendance: attendance, ticketID: ticketID, date: date, seats: seats, show: show, tickets: tickets, dateIndex: dateIndex)
    }
}
