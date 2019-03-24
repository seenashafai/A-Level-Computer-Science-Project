//
//  UserTicket.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 10/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct UserTicket {
    
    var attendance: Bool = false
    var ticketID: Int = 0
    var dateIndex: Int = 0
    var date: Timestamp
    var seats: String = ""
    var show: String = ""
    var tickets: String = ""
    
    var dictionary: [String: Any] {
        return [
            "ticketID": ticketID,
            "dateIndex": dateIndex,
            "attendance": attendance,
            "date": date,
            "seats": seats,
            "show": show,
            "tickets": tickets
        ]
    }
}


extension UserTicket {
    init?(dictionary: [String: Any]) {
        guard let attendance = dictionary["attendance"] as? Bool,
            let dateIndex = dictionary["dateIndex"] as? Int,
            let date = dictionary["date"] as? Timestamp,
            let ticketID = dictionary["ticketID"] as? Int,
            let seats = dictionary["seats"] as? String,
            let show = dictionary["show"] as? String,
            let tickets = dictionary["tickets"] as? String
            else {return nil}
        
        self.init(attendance: attendance, ticketID: ticketID, dateIndex: dateIndex, date: date, seats: seats, show: show, tickets: tickets)
    }
}
