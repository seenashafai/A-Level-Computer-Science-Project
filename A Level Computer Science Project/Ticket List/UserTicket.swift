//
//  UserTicket.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 10/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import Foundation

struct UserTicket {
    
    var attendance: Bool = false
    var ticketID: Int = 0
    var date: String = ""
    var seats: String = ""
    var show: String = ""
    var tickets: String = ""
    
    var dictionary: [String: Any] {
        return [
            "ticketID": ticketID,
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
            let date = dictionary["date"] as? String,
            let ticketID = dictionary["ticketID"] as? Int,
            let seats = dictionary["seats"] as? String,
            let show = dictionary["show"] as? String,
            let tickets = dictionary["tickets"] as? String
            else {return nil}
        
        self.init(attendance: attendance, ticketID: ticketID, date: date, seats: seats, show: show, tickets: tickets)
    }
}
