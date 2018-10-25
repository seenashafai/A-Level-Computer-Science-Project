//
//  PKUser.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 25/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation

struct PKUser {
    
    let userID: Int
    let name: String
    let email: String
    let seatRef: String
    
    var dictionary: [AnyHashable: Any] {
        return [
            "userID": userID,
            "name": name,
            "email": email,
            "seatRef": seatRef
        ]
    }
}


extension PKUser {
    init?(dictionary: [AnyHashable : Any]) {
        guard let userID = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String,
            let seatRef = dictionary["seatRef"] as? String
            
            else {return nil}
        
        self.init(userID: userID, name: name, email: email, seatRef: seatRef)
    }
    
}
