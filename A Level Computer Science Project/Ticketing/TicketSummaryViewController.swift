//
//  TicketSummaryViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 22/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import PassKit

class TicketSummaryViewController: UIViewController, PKAddPassesViewControllerDelegate {

    @IBAction func addPassButtonPressed(_ sender: Any) {
        
        //load StoreCard.pkpass from resource bundle
        let filePath = Bundle.main.path(forResource: "StoreCard", ofType: "pkpass")
        let data = NSData(contentsOfFile: filePath ?? "") as Data?
        let error: Error?
        
        var pass = PKPass()
        var passLib = PKPassLibrary()
        
        //check if pass library contains this pass already
        if passLib.containsPass(pass) {
            
            //pass already exists in library, show an error message
            print("pass already exists")
        } else {
            
            //present view controller to add the pass to the library
            var vc = PKAddPassesViewController(pass: pass)
            vc!.delegate = self as? PKAddPassesViewControllerDelegate
            present(vc!, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check if pass library is available
        if !PKPassLibrary.isPassLibraryAvailable() {
            print("unavailable")
        }
        var passLib = PKPassLibrary()

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
