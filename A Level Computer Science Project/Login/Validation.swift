//  Validation.swift
//  A Level Computer Science Project
//  Copyright © 2018 Seena Shafai. All rights reserved.

import Foundation
import LocalAuthentication

class Validation {
    
    //Email Validation
    func isValidEmail(emailStr:String) -> Bool {
        //Head(letter, number, special) + @ + Provider(letter/number) + . + Domain(letter, between 2 and 64 chars) + any additional domains
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}(.[A-Za-z]{2,64})?"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx) //Create email test with regex and string matching function
        return emailTest.evaluate(with: emailStr) //Evaluate regex on email string input
    }
    
    //Password Validation
    func isValidPass(passStr:String) -> Bool {
        //Minimum six characters, at least one uppercase letter, one lowercase letter and one number
        let passRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{6,}$"
        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx) //Create password test with regex and string matching function
        return passTest.evaluate(with: passStr)//Evaluate regex on password string input
    }
    
    //Validate confirmation entries
    func isValueMatch(str1: String, str2: String) -> Bool //Takes in two variables
    {
        if str1 == str2
        {
            //Returns true if variables match
            return true
        }
        else
        {   //Returns false if variables do not match
            return false
        }
    }
    
    //Biometric Authentication
    func authenticateUser(reason: String) -> Bool
    {
        //Instantiate Local Authentication context
        let context: LAContext = LAContext()
        var auth: Bool? //Create empty authentication boolean
        let group = DispatchGroup() //Open new dispatch group/thread
        group.enter() //Enter new thread

        //Check if device is compatible (iOS 10+ is fine)
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        {
            //Execute biometric/keypad depending on device
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: { (success, error) in
                if success //If returned as a success
                {
                    //Output for debugging
                    print("successful biometric auth")
                    //Tweak a variable from within the custom thread
                    DispatchQueue.global(qos: .default).async {
                        auth = true //Set auth to true
                        group.leave() //Exit thread having updated the auth bool
                    }
                }
                else //Bio auth failed
                {
                    //Output for debugging
                    print("unsuccessful biometric auth")
                    auth = false //Set auth bool to false
                }
            })
        }
        else { //Bio auth not supported
            //Output for debugging
            print("bio auth not supported")
            auth = false //Set auth to false
        }
        //Wait for thread to be exited (complete)
        group.wait()
        return auth! //Return authentication state

    }
}

