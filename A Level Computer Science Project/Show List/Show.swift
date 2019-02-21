//
//  Show.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 05/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Show {
    let name: String
    let category: String
    let date: Timestamp
    
    //Provide dictionary framework for class
    var dictionary: [String: Any] {
        return [
            "name": name,
            "Category": category,
            "Date": Timestamp()
        ]
    }
}

extension Show {
    //Initialise class dictionary
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
        let category = dictionary["Category"] as? String,
        let date = dictionary["Date"] as? Timestamp
            else {return nil}
        
        self.init(name: name, category: category, date: date)
    }
}


