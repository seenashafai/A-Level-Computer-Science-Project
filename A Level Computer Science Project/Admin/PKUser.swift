//
//  PKUser.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 25/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation

struct PKUser: Codable {
    
    let id: Int
    let name: String
    let email: String
    let seatRef: String
    let created_at: String
    let updated_at: String
    
    
    var dictionary: [String: AnyObject] {
        return [
            "id": id as AnyObject,
            "name": name as AnyObject,
            "email": email as AnyObject,
            "seatRef": seatRef as AnyObject,
            "created_at": created_at as AnyObject,
            "updated_at": updated_at as AnyObject
            
        ]
    }
}


extension PKUser {
    init?(dictionary: [String : AnyObject]) {
        guard let id = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String,
            let seatRef = dictionary["seatRef"] as? String,
            let created_at = dictionary["created_at"] as? String,
            let updated_at = dictionary["updated_at"] as? String
            
            else {return nil}
        
        self.init(id: id, name: name, email: email, seatRef: seatRef, created_at: created_at, updated_at: updated_at)
    }
    
}
