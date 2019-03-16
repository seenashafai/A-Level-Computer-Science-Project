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
    var starRating: Double = 0.0
    var description: String = ""
    var email: String = ""
    
    var dictionary: [String: Any] { //Define dictionary conversion method
        return [
            "starRating": starRating,
            "description": description,
            "email": email
        ]
    }
}

extension Review { //Extend class functionality with dictionary filler
    init?(dictionary: [String: Any]) { //Initialise database
        guard let starRating = dictionary["starRating"] as? Double,
            let description = dictionary["description"] as? String,
            let email = dictionary["email"] as? String

            else {return nil}
        
        //Initialise method and extension variables
        self.init(starRating: starRating, description: description, email: email)
    }
}

