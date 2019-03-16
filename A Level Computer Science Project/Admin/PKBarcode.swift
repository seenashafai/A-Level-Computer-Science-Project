//
//  PKBarcode.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 25/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import Foundation

struct PKBarcode: Codable {
    
    let pass_type_id: String
    let serial_number: String
    let authentication_token: String
}

class Barcode {
    
    //Decode JSON into Barcode variables
    func decodeJSONString(JSONString: String) -> PKBarcode?
    {
        var barcode: PKBarcode? //Initialise empty barcode response
        
        //JSON Initialisation
        let JSONData = Data(JSONString.utf8) //Convert string to Swift 'Data' type for decoding
        let decoder = JSONDecoder() //Initialise JSON Decoder
       
        //Decode JSON into PKBarcode object
        do {//Do-try-catch
            barcode = try decoder.decode(PKBarcode.self, from: JSONData) //Attempt to decode JSON into PKBarcode
        } catch { //Handle error thrown
            print(error) //Output error
        }
        
        return barcode
    }
}
