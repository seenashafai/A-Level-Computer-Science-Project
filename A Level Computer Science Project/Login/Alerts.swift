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
    
    func localizedErrorAlertController(error: String) -> UIAlertController
    {
        let localizedErrorAlert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        localizedErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return localizedErrorAlert
    }
    
    func validationErrorAlertController(message: String) -> UIAlertController
    {
        let validationErrorAlert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        validationErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return validationErrorAlert
    }
}