//
//  Transaction.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 26/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation

struct Transaction {

    var transactionID: Int = 0
    var date: String = ""
    var email: String = ""
    var house: String = ""
    var seats: [Int] = []
    var show: String = ""
    var tickets: Int = 0
    
    var dictionary: [String: Any] {
        return [
            "transactionID": transactionID,
            "date": date,
            "email": email,
            "house": house,
            "seats": seats,
            "show": show,
            "tickets": tickets
        ]
    }
}


extension Transaction {
    init?(dictionary: [String: Any]) {
        guard let transactionID = dictionary["transactionID"] as? Int,
            let date = dictionary["date"] as? String,
            let email = dictionary["email"] as? String,
            let house = dictionary["house"] as? String,
            let seats = dictionary["seats"] as? [Int],
            let show = dictionary["show"] as? String,
            let tickets = dictionary["tickets"] as? Int
            else {return nil}
        self.init(transactionID: transactionID, date: date, email: email, house: house, seats: seats, show: show, tickets: tickets)
    }
}
