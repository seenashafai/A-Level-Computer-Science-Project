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
    var starRating: Double = 0
    var review: String = ""
    var email: String = ""
    
    var dictionary: [String: Any] {
        return [
            "starRating": starRating,
            "review": review,
            "email": email,
        ]
    }
}

extension Review {
    init?(dictionary: [String: Any]) {
        guard let starRating = dictionary["starRating"] as? Double,
            let review = dictionary["review"] as? String,
            let email = dictionary["email"] as? String

            else {return nil}
        
        self.init(starRating: starRating, review: review, email: email)
    }
}

