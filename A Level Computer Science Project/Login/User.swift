//
//  User.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 16/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth


struct User {
    
    let firstName: String
    let lastName: String
    let emailAddress: String
    let house: String
    let block: String
    let admin: Int
    let ticketsBooked: Int
    let showsBookedArray: [String]
    
    var dictionary: [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "emailAddress": emailAddress,
            "house": house,
            "block": block,
            "admin": admin,
            "ticketsBooked": ticketsBooked,
            "showsBookedArray": showsBookedArray
        ]
    }
}

extension User {
    init?(dictionary: [String: Any]) {
        guard let firstName = dictionary["firstName"] as? String,
        let lastName = dictionary["lastName"] as? String,
        let emailAddress = dictionary["emailAddress"] as? String,
        let house = dictionary["house"] as? String,
        let block = dictionary["block"] as? String,
        let admin = dictionary["admin"] as? Int,
        let ticketsBooked = dictionary["ticketsBooked"] as? Int,
        let showsBookedArray = dictionary["showsBookedArray"] as? [String]

        
            else {return nil}
        self.init(firstName: firstName, lastName: lastName, emailAddress: emailAddress, house: house, block: block, admin: admin, ticketsBooked: ticketsBooked, showsBookedArray: showsBookedArray)
     }
}

class FirebaseUser
{
    func isUserSignedIn() -> Bool
    {
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser?.email)
            return true
        } else {
            return false
        }
    }
    
    func getCurrentUserEmail() -> String
    {
        var userEmail: String = ""
        userEmail = (Auth.auth().currentUser?.email)!
        print(userEmail)
        return userEmail

    }
    
    func getCurrentUserDisplayName() -> String
    {
        var userDisplayName: String = ""
        if let userDisplayName = (Auth.auth().currentUser?.displayName)
        {
            print(userDisplayName)
            return userDisplayName
        }
        else
        {
            print("no displayName")
            userDisplayName = ""
        }
        return userDisplayName
    }
    
    func isUserEmailVerified() -> Bool
    {
        if Auth.auth().currentUser?.isEmailVerified == true
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func sendUserValidationEmail()
    {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if let error = error {
                print(error.localizedDescription, "error")
            } else
            {
                print("email sent")
            }
        }
    }
    


    
}
