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
            

    
}
