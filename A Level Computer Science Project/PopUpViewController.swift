//
//  PopUpViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 17/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    var reviewDescription: String?
    
    @IBAction func dismissPopUpAction(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        textView.text == reviewDescription
        // Do any additional setup after loading the view.
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
