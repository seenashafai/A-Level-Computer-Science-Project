//
//  Alerts.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 03/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation
import UIKit

class Alerts {
    
    func localizedErrorAlertController(message: String) -> UIAlertController
    {
        let localizedErrorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        localizedErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return localizedErrorAlert
    }
    
    func validationErrorAlertController(message: String) -> UIAlertController
    {
        let validationErrorAlert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        validationErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return validationErrorAlert
    }
    
    func invalidHouseErrorAlertController() -> UIAlertController
    {
        let invalidHouseErrorAlert = UIAlertController(title: "Error", message: "Please select a house", preferredStyle: .alert)
        invalidHouseErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return invalidHouseErrorAlert
    }
    
    func serverConnectionError() -> UIAlertController
    {
        let serverConnectionError = UIAlertController(title: "Connection Error", message: "Unable to connect to the server to download your ticket. Please check your internet connection and try again", preferredStyle: .alert)
        serverConnectionError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return serverConnectionError
    }
    
    func alreadyInWalletInfo() -> UIAlertController
    {
        let alreadyInWalletInfo = UIAlertController(title: "Information", message: "This pass is already in your wallet. Thanks!", preferredStyle: .alert)
        alreadyInWalletInfo.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alreadyInWalletInfo
    }
    
    func addedToWalletInfo() -> UIAlertController
    {
        let addedToWalletInfo = UIAlertController(title: "Information", message: "This ticket has been added to the Wallet app. Please present the ticket at the door", preferredStyle: .alert)
        addedToWalletInfo.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return addedToWalletInfo
    }
    
    func userAlreadyHasTicket() -> UIAlertController
    {
        let userAlreadyHasTicket = UIAlertController(title: "Information", message: "You already have a ticket for this event. You may only request one batch of tickets per event", preferredStyle: .alert)
        userAlreadyHasTicket.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return userAlreadyHasTicket
    }
}
