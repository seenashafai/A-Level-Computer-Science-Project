//
//  Show.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 05/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation
import FirebaseFirestore


struct Show: Comparable

{
    
    //Conforming to comparable protocol
    static func < (lhs: Show, rhs: Show) -> Bool {
        return lhs.date.seconds < rhs.date.seconds
    }
    
    let name: String
    let category: String
    let date: Timestamp
    let availableTickets: Int
    
    var dictionary: [String: Any] {
        return [
            "Date": Timestamp(),
            "name": name,
            "Category": category,
            "availableTickets": availableTickets
        ]
    }
}

extension Show {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
        let category = dictionary["Category"] as? String,
        let date: Timestamp = dictionary["Date"] as? Timestamp,
        let availableTickets = dictionary["availableTickets"] as? Int
            
           // let date = dictionary["Date"] as? String
            else {return nil}
        
        self.init(name: name, category: category, date: date, availableTickets: availableTickets)
    }
    
}

class showFunctions {
    
    func getDateFromEpoch(timeInterval: Double) -> String
    {
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}



