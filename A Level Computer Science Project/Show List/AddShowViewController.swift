//
//  AddShowViewController.swift
//  A Level Computer Science Project
//
//  Created by Chronicle on 02/11/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PKHUD

class AddShowViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties
    var db: Firestore!
    var show: Show?
    var imagePicker: UIImagePickerController = UIImagePickerController()
    let storage = Storage.storage()
    let showFunc = showFunctions()
    var edit: Bool?

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
        if edit == true
        {
            self.performSegue(withIdentifier: "toMoreEdit", sender: nil)
        }
        else
        {
            self.performSegue(withIdentifier: "toMoreDetails", sender: self)
        }
    }
    
    //MARK: - IB Links
    @IBOutlet var showNameTextField: UITextField!
    @IBOutlet var categorySegmentedControl: UISegmentedControl!
    @IBOutlet var venueSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePickerView: UIDatePicker!

    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if edit == true //Selection to determine whether view is in edit or add mode.
        {
            navigationItem.title = "Edit Show - \(show?.name ?? "")" //Set navigation bar title at top of view
            showNameTextField.text = show?.name //Set 'show name' textfield to name of show to edit
            initialiseVenueForEditing()
            initialiseCategoryForEditing()
            initialiseDatePickerForEditing()
        }
        
        db = Firestore.firestore()
        datePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        
        // Do any additional setup after loading the view.
    }
    
    func setVariables() -> [String: Any]
    {
        let date = showFunc.convertDate(date: datePickerView!.date as NSDate)
        let venue = showFunc.setData(index: venueSegmentedControl.selectedSegmentIndex, var1: "Farrer Theatre", var2: "Caccia Studio", var3: "Empty Space")
        let name = showNameTextField.text
        let director = "anyDirector"
        let category = showFunc.setData(index: categorySegmentedControl.selectedSegmentIndex, var1: "House", var2: "School", var3: "Independent")
        let availableTickets = showFunc.setAvailableSeats(venue: venue as? String)
        let showDataDict: [String: Any] = [
            "name": name as Any,
            "venue": venue as Any,
            "availableTickets": availableTickets as Any,
            "Category": category as Any,
            "Date": date as Any,
            "director": director as Any
        ]
        return showDataDict
    }
    
    func initialiseVenueForEditing()
    {
        switch show?.venue {
        case "Farrer Theatre":
            venueSegmentedControl.selectedSegmentIndex = 0
        case "Caccia Studio":
            venueSegmentedControl.selectedSegmentIndex = 1
        case "Empty Space":
            venueSegmentedControl.selectedSegmentIndex = 2
        case .none:
            fatalError("No venue currently set for selected show")
        case .some(_): //Default - if there are no matching cases
            fatalError("No matching cases for switch variable \(String(describing: show?.venue))")
        }
    }
    
    func initialiseCategoryForEditing()
    {
        switch show?.category {
        case "House":
            categorySegmentedControl.selectedSegmentIndex = 0
        case "School":
            categorySegmentedControl.selectedSegmentIndex = 1
        case "Independent":
            categorySegmentedControl.selectedSegmentIndex = 2
        case .none: //Where no value is present
            fatalError("No category currently set for selected show")
        case .some(_): //Default- if there are no matching cases
            fatalError("No matching cases for switch variable \(String(describing: show?.category))")
        }
    }
    
    func initialiseDatePickerForEditing()
    {
        datePickerView.setDate((show?.date.dateValue())!, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMoreEdit"
        {
            let destVC = segue.destination as! MoreDetailsViewController
            destVC.showDataDict = setVariables()
            destVC.show = show
            destVC.edit = edit
        }
        if segue.identifier == "toMoreDetails"
        {
            let destVC = segue.destination as! MoreDetailsViewController
            destVC.showDataDict = setVariables()
            destVC.edit = edit
        }
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
