//
//  Ticket.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 17/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation

struct Ticket {
    
    var availableTickets: Int = 0
    var availableSeats: [Int] = []
    var ticketHolders: [String] = []
    
    var dictionary: [String: Any] {
        return [
            "availableSeats": availableSeats,
            "ticketHolders": ticketHolders,
            "availableTickets": availableTickets
        ]
    }
}


extension Ticket {
    init?(dictionary: [String: Any]) {
        guard let availableTickets = dictionary["availableTickets"] as? Int,
            let ticketHolders = dictionary["ticketHolders"] as? [String],
            let availableSeats = dictionary["availableSeats"] as? [Int]
            else {return nil}
        self.init(availableTickets: availableTickets, availableSeats: availableSeats, ticketHolders: ticketHolders)
    }
}
