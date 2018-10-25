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
    var testUser = [PKTestUser]()

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //Begin connection session
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else
                {
                    //Connection failed
                    print(error?.localizedDescription ?? "Response Error", "RESPONSE ERRORINIO")
                    return
                }
            do {
                //Decode json response
                let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                //Map json response to array
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    return
                }
                //Map json array to PKTestUser struct
                for dic in jsonArray{
                    self.testUser.append(PKTestUser(dic))
                }
                print(self.testUser[0].title, "testUserID")
            
                //Decode error
            } catch let parsingError {
                print("Error", parsingError)
            }
            
        }
        task.resume()
        
    }


}
