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
    
    var dictionary: [String: Any] {
        return [
            "Date": Timestamp(),
            "name": name,
            "Category": category
        ]
    }
}

extension Show {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
        let category = dictionary["Category"] as? String,
        let date: Timestamp = dictionary["Date"] as? Timestamp
            
           // let date = dictionary["Date"] as? String
            else {return nil}
        
        self.init(name: name, category: category, date: date)
    }
    
}


