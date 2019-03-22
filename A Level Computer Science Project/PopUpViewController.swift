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
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8) //Set background colour to gray
        textView.text = reviewDescription //Set text as review description
    }
}
