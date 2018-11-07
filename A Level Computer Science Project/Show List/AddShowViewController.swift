//
//  AddShowViewController.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 02/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import PKHUD

class AddShowViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties
    var db: Firestore!
    var show: Show?
    var imagePicker: UIImagePickerController = UIImagePickerController()
    let storage = Storage.storage()
    let showFunc = showFunctions()

    //MARK: - Image Picker Methods
    @IBOutlet var imageView: UIImageView!
    @IBAction func pickImageAction(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageView.image = selectedImage
        }
    dismiss(animated: true, completion: nil)
    }
    
    //Submitting form
    @IBAction func confirmAction(_ sender: Any) {
        let date = showFunc.convertDate(date: datePickerView!.date as NSDate)
        let venue = showFunc.setData(index: venueSegmentedControl.selectedSegmentIndex, var1: "Farrer Theatre", var2: "Caccia Studio", var3: "Empty Space")
        let name = showNameTextField.text
        let category = showFunc.setData(index: categorySegmentedControl.selectedSegmentIndex, var1: "House", var2: "School", var3: "Independent")
        let availableTickets = showFunc.setAvailableSeats(venue: venue as? String)
        let showRef = db.collection("shows").document(name!)
        showRef.setData([
            "name": name as Any,
            "venue": venue as Any,
            "availableTickets": availableTickets as Any,
            "Category": category as Any,
            "Date": date as Any
        ])
        HUD.flash(HUDContentType.success, delay: 0.3)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - IB Links
    @IBOutlet var showNameTextField: UITextField!
    @IBOutlet var categorySegmentedControl: UISegmentedControl!
    @IBOutlet var venueSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePickerView: UIDatePicker!

    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        datePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
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
