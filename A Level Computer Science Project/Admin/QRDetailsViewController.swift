//
//  QRDetailsViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 25/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class QRDetailsViewController: UIViewController {

    //MARK: - Properties
    var passVar: String = ""
    let APIEndpoint = "http://192.168.1.24:6789"
    var barcodeMethods = Barcode()
    
    func decodeJSONString()
    {
        //JSON Decoding
        let barcode = barcodeMethods.decodeJSONString(JSONString: passVar)

        let user = barcodeMethods.sendJSONRequest(withMethod: "GET", APIEndpoint: APIEndpoint, path: "/user_for_pass/\(String(describing: barcode!.pass_type_id))/\(String(describing: barcode!.serial_number))/\(String(describing: barcode!.authentication_token))", formFields: nil) { user, error in
            guard user != nil else
            {
                print(error)
                return
            }
            print(user)
        }
    }

    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(passVar, "passVar")
        decodeJSONString()
        
    }

}

//guard let url = URL(string: "http://192.168.1.24:6789/user_for_pass/\(barcode.pass_type_id)/\(barcode.serial_number)/\(barcode.authentication_token)") else {return}
