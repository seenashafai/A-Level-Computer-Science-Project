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
    var numberOfTicketHolders: Int = 0
    var ticketHolders: [String] = []
    
    var dictionary: [String: Any] {
        return [
            "availableTickets": availableTickets,
            "numberOfTicketHolders": numberOfTicketHolders,
            "ticketHolders": ticketHolders
        ]
    }
}


extension Ticket {
    init?(dictionary: [String: Any]) {
        guard let availableTickets = dictionary["availableTickets"] as? Int,
            let numberOfTicketHolders = dictionary["numberOfTicketHolders"] as? Int,
            let ticketHolders = dictionary["ticketHolders"] as? [String]
            else {return nil}
        self.init(availableTickets: availableTickets, numberOfTicketHolders: numberOfTicketHolders, ticketHolders: ticketHolders)
    }
}
