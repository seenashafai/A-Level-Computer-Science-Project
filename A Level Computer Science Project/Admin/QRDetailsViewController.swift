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
    
    func decodeJSONString()
    {
        //JSON Decoding
        let jsonData = Data(passVar.utf8) //Convert string to Swift 'Data' type for decoding
        let decoder = JSONDecoder() //Initialise JSON Decoder
        do {
            let barcode = try decoder.decode(PKBarcode.self, from: jsonData) //Decode with decoder & data
            print(barcode.authentication_token, "authtoken")
            
            sendJSONRequest(withMethod: "GET", path: "/user_for_pass/\(barcode.pass_type_id)/\(barcode.serial_number)/\(barcode.authentication_token)", formFields: nil)
            
        } catch {
            print(error)
        }
    }
    
    func sendJSONRequest(withMethod method: String?, path: String?, formFields: NSDictionary?) {
        let urlString = "\(APIEndpoint)\(path ?? "")"
        let url = URL(string: urlString)
        var request: NSMutableURLRequest? = nil
        if let anUrl = url {
            request = NSMutableURLRequest(url: anUrl)
        }
        request?.httpMethod = method ?? ""
        if formFields != nil {
            request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            var bodyString = ""
            formFields!.enumerateKeysAndObjects({ key, value, stop in
                let urlEncodedKey = (key as? NSString)?.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
                let urlEncodedValue = (value as? NSString)?.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
                bodyString += "\(urlEncodedKey ?? "")=\(urlEncodedValue ?? "")&"
            })
            let bodyData: Data? = bodyString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            request?.httpBody = bodyData
            request?.setValue("\(bodyData?.count ?? 0)", forHTTPHeaderField: "Content-Length")
        }
        print("Sending request: \(String(describing: request))")
        NSURLConnection.sendAsynchronousRequest(request! as URLRequest, queue: OperationQueue.main, completionHandler: { response, data, error in
                if data != nil {
                    if let aData = data {
                        let result = try? JSONSerialization.jsonObject(with: aData, options: [JSONSerialization.ReadingOptions.allowFragments]) as? [String: AnyObject]
                        let resultStruct = PKUser(dictionary: result as! [String : AnyObject])
                        print(resultStruct?.name, "name")
                        
                    }
                }
                else{
                print(error!, "networking error")
            }
        })
    }

    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(passVar, "passVar")
        decodeJSONString()
        
    }

}

//guard let url = URL(string: "http://192.168.1.24:6789/user_for_pass/\(barcode.pass_type_id)/\(barcode.serial_number)/\(barcode.authentication_token)") else {return}
