//  Ticket.swift
//  Copyright © 2018 Seena Shafai. All rights reserved.

import Foundation

struct Ticket {
    
    //Define variables
    var availableTickets: Int = 0
    var availableSeats: [Int] = []
    var ticketHolders: [String] = []
    
    //Implement ticket dictionary method
    var dictionary: [String: Any] {
        return [
            "availableSeats": availableSeats,
            "availableTickets": availableTickets,
            "ticketHolders": ticketHolders
        ]
    }
}


extension Ticket { //Extension to ticket dictionary method- initialises the dictionary by mapping the database fields to dictionary fields
    init?(dictionary: [String: Any]) {
        guard let availableTickets = dictionary["availableTickets"] as? Int,
            let ticketHolders = dictionary["ticketHolders"] as? [String],
            let availableSeats = dictionary["availableSeats"] as? [Int]
            else {return nil}
        self.init(availableTickets: availableTickets, availableSeats: availableSeats, ticketHolders: ticketHolders)
    }
}

