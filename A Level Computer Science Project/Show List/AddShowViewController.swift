//
//  AddShowViewController.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 02/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase

class AddShowViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    

    //MARK: - Properties
    var db: Firestore!
    var show: Show?
    var imagePicker: UIImagePickerController = UIImagePickerController()

    
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
    
    @IBAction func confirmAction(_ sender: Any) {
        let date = convertDate()
        let venue = setVenue()
        let name = showNameTextField.text
        let category = setCategory()
        let availableTickets = setAvailableSeats(venue: venue)
        let showRef = db.collection("shows").document(name!)
        showRef.setData([
            "name": name as Any,
            "venue": venue as Any,
            "availableTickets": availableTickets as Any,
            "Category": category as Any,
            "Date": date as Any
        ])
    }
    
    
    @IBOutlet var showNameTextField: UITextField!
    @IBOutlet var categorySegmentedControl: UISegmentedControl!
    @IBOutlet var venueSegmentedControl: UISegmentedControl!
    @IBOutlet var housePickerView: UIPickerView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    
    func convertDate() -> NSDate?
    {
        let timeStamp: NSDate = datePickerView!.date as NSDate
        return timeStamp
    }
    
    func setVenue() -> String?
    {
        let index = venueSegmentedControl.selectedSegmentIndex
        let venue: String?
        switch index {
            case 0:
                venue = "Farrer Theatre"
                return venue
            case 1:
                venue = "Caccia Studio"
                return venue
            case 2:
                venue = "Empty Space"
                return venue
            
        default:
            venue = ""
            return venue
        }
    }
    
    func setAvailableSeats(venue: String?) -> Int?
    {
        var availableSeats: Int?
        switch venue {
        case "Farrer Theatre":
            availableSeats = 400
            return availableSeats
        case "Caccia Studio":
            availableSeats = 100
            return availableSeats
        case "Empty Space":
            availableSeats = 50
            return availableSeats
            
        default:
            availableSeats = 0
            return availableSeats
        }
    }
    
    func setCategory() -> String?
    {
        let index = categorySegmentedControl.selectedSegmentIndex
        let category: String?
        switch index {
            case 0:
                category = "House"
                return category
            case 1:
                category = "School"
                return category
            case 2:
                category = "Independent"
                return category
            
        default:
            category = ""
            return  category
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
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
