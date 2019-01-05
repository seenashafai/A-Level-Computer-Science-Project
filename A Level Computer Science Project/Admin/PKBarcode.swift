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
    
    func decodeJSONString(JSONString: String) -> PKBarcode?
    {
        var barcode: PKBarcode?
        //JSON Decoding
        let JSONData = Data(JSONString.utf8) //Convert string to Swift 'Data' type for decoding
        let decoder = JSONDecoder() //Initialise JSON Decoder
        do {
            barcode = try decoder.decode(PKBarcode.self, from: JSONData) //Decode with decoder & data
            print(barcode?.authentication_token, "authtoken")
        } catch {
            print(error)
        }
        return barcode
    }
    
    func sendJSONRequest(withMethod method: String?, APIEndpoint: String, path: String?, formFields: NSDictionary?, completionHandler: @escaping (PKUser?, Error?) -> ())
    {
        var user: PKUser!
        let urlString = "\(APIEndpoint)\(path ?? "")"
        let url = URL(string: urlString)
        var request: NSMutableURLRequest? = nil
        if let anUrl = url {
            request = NSMutableURLRequest(url: anUrl)
        }
        request?.httpMethod = method ?? ""
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if formFields != nil {
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
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
                    if result != nil
                    {
                        let resultStruct = PKUser(dictionary: result as! [String : AnyObject])
                        print(resultStruct?.name, "name")
                        user = resultStruct
                        print(user?.email, "name")
                        completionHandler(user, nil)
                    }
                    else
                    {
                        print("result = nil")
                        print(request?.allHTTPHeaderFields)
                    }
                }
            }
            else{
                print(error!, "networking error")
                return 
            }
            print(user.email, "userEmail")

        })
    }
    
    
    func sendJSONRequestWithoutCompletionHandler(withMethod method: String?, APIEndpoint: String, path: String?, formFields: NSDictionary?)
    {
        var user: PKUser!
        let urlString = "\(APIEndpoint)\(path ?? "")"
        let url = URL(string: urlString)
        var request: NSMutableURLRequest? = nil
        if let anUrl = url {
            request = NSMutableURLRequest(url: anUrl)
        }
        request?.httpMethod = method ?? ""
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if formFields != nil {
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
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
                    if result != nil
                    {
                        let resultStruct = PKUser(dictionary: result as! [String : AnyObject])
                        print(resultStruct?.name, "name")
                        user = resultStruct
                        print(user?.email, "name")
                    }
                    else
                    {
                        print("result = nil")
                        print(request?.allHTTPHeaderFields)
                    }
                }
            }
            else{
                print(error!, "networking error")
                return
            }
            print(user.email, "userEmail")
            
        })
    }
    
}
