//  Show.swift
//  Copyright © 2018 Seena Shafai. All rights reserved.

import Foundation
import FirebaseFirestore

struct Show
{
    let name: String
    let category: String
    let date: Timestamp
    let availableTickets: Int
    let venue: String
    let description: String
    let director: String
    let house: String
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "Category": category,
            "Date": Timestamp(),
            "availableTickets": availableTickets,
            "venue": venue,
            "description": description,
            "director": director,
            "house": house
        ]
    }
}

extension Show {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
        let category = dictionary["Category"] as? String,
        let date: Timestamp = dictionary["Date"] as? Timestamp,
        let availableTickets = dictionary["availableTickets"] as? Int,
        let venue = dictionary["venue"] as? String,
        let description = dictionary["description"] as? String,
        let director = dictionary["director"] as? String,
        let house = dictionary["house"] as? String
        
            else {return nil}
        
        self.init(name: name, category: category, date: date, availableTickets: availableTickets, venue: venue, description: description, director: director, house: house)
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
    
    func setData(index: Int, var1: Any, var2: Any, var3: Any) -> Any?
    {
        var pickedVar: Any
        switch index {
        case 0:
            pickedVar = var1
            return pickedVar
        case 1:
            pickedVar = var2
            return pickedVar
        case 2:
            pickedVar = var3
            return pickedVar
            
        default:
            pickedVar = ""
            return pickedVar
        }
    }
    
    func setAvailableSeats(venue: String?) -> Int?
    {
        var availableSeats: Int?
        switch venue {
        case "Farrer Theatre":
            availableSeats = 400
            return availableSeats
        case "Caccia Studio":
            availableSeats = 100
            return availableSeats
        case "Empty Space":
            availableSeats = 50
            return availableSeats
            
        default:
            availableSeats = 0
            return availableSeats
        }
    }
    
    func convertDate(date: NSDate) -> NSDate?
    {
        let timeStamp: NSDate = date
        return timeStamp
    }
    
    func timestampDateConverter(timestamp: Timestamp, format: String) -> String
    {
        let date: Date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
    
    func suffixFromTimestamp(timestamp: Timestamp) -> String
    {
        let calendar = Calendar.current
        let date: Date = timestamp.dateValue()
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 33: return "rd"
        default: return "th"
        }
    }
    
    func suffixFromDate(date: Date) -> String
    {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 33: return "rd"
        default: return "th"
        }
    }
    
    //Increment date
    func DateFromStart(date: Date, index: Int) -> Date
    {
        let modifier = index - 1 //Number of days to add on to start date
        //Add modifier to start date
        let modifiedDate = Calendar.current.date(byAdding: .day, value: modifier, to: date)
        //Return modified date
        return modifiedDate!
    }
    
    //Format modified date
    func formatDate(date: Date, format: String) -> String
    {
        //Initialise date formatter
        let dateFormatter = DateFormatter()
        //Assign given format to date
        dateFormatter.dateFormat = format
        //Format date using parameters
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate //Return formatted date as string
    }
}





