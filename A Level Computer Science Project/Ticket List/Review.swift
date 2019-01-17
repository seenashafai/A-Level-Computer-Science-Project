//
//  Review.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 11/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import Foundation

struct Review
{
    var starRating: Int = 0
    var description: String = ""
    var email: String = ""
    
    var dictionary: [String: Any] {
        return [
            "starRating": starRating,
            "description": description,
            "email": email
        ]
    }
}

extension Review {
    init?(dictionary: [String: Any]) {
        guard let starRating = dictionary["starRating"] as? Int,
            let description = dictionary["description"] as? String,
            let email = dictionary["email"] as? String

            else {return nil}
        
        self.init(starRating: starRating, description: description, email: email)
    }
}

