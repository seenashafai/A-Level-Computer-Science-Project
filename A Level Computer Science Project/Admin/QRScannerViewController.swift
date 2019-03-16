//
//  QRScannerViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 24/10/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import AVFoundation
import MaterialComponents.MaterialSnackbar
import PKHUD
import Firebase
import FirebaseFirestore
import Alamofire.Swift

class QRScannerViewController: UIViewController {

    //MARK: - API Properties
    var APIEndpoint = "https://ftpkdist.serveo.net"
    var returnedUser: PKUser?
    var PKBarcode = Barcode()
    var db: Firestore!

    
    //MARK: - Properties
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var show: String?
    var dateIndex: String?


    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

        //Get the back-facing camera for capturing videos
        //Device: built-in dual camera, Media: Video, Position: rear (back)
        let rearCamera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        //Validate...
        //Ensure that the rear camera actually exists
        guard let captureDevice = rearCamera.devices.first else {
            print("Failed to get the camera device") //Output error message to console
            return
        }
        
        //Begin do-try-catch error handling
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            print(error) //Output error
            return //Exit function
        }
        
        //Initialise video preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession) //Assign capture session to preview layer
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill //Set aspect fill of view (aesthetics)
        videoPreviewLayer?.frame = view.layer.bounds //Assign frame as the boundaries of the device
        
        //Set video preview layer as sublayer
        view.layer.addSublayer(videoPreviewLayer!)
        
        //Start video capture session
        captureSession.startRunning()
    }
    
    //Executes when view is dismissed
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //End capture session as view is dismissed
        captureSession.stopRunning()
    }

    
    func presentQROutput(decodedMessage: String)
    {
        //JSON Decoding to retrieve individual components of barcode
        let barcode = PKBarcode.decodeJSONString(JSONString: decodedMessage)
        
        //Define endpoint to retrieve user details from barcode data
        let endpoint = APIEndpoint + "/user_for_pass/\(String(describing: barcode!.pass_type_id))/\(String(describing: barcode!.serial_number))/\(String(describing: barcode!.authentication_token))"
        
        //Send HTTP GET request using new endpoint, default JSON encoding and "application/json" content type header
        Alamofire.request(endpoint, method: HTTPMethod.get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON
            { response in //Closure
            
                print(response.description)
                var email: String?
                var show: String?
                var name: String?
                var seats: String?
                
            //Convert JSON result to dictionary with 'result.value'
            if let data = response.result.value as? [String: Any]
            {
                //Extract data from dictionary and assign to local variables
                email = data["email"] as? String
                show = data["show"] as? String
                name = data["name"] as? String
                seats = data["seatRef"] as? String
            }
            //Present snackbar with name and seat variables
            self.presentSnackbar(name: name!, seats: seats!)
            //Set user attendance boolean to True
            self.userAttended(email: email!, show: show!)
        }
        

    }
    func userAttended(email: String, show: String) //Take user email and show for ticket
    {
        //Define location of attendance boolean in user's ticket
        let ticketRef = db.collection("users").document(email).collection("tickets").document(show)
        ticketRef.updateData([
            "attendance": true //Set attendance to true (bool)
            ])
        //Define location of show statistics
        let statsRef = db.collection("users").document(show).collection(dateIndex!).document("statistics")
        statsRef.getDocument {(documentSnapshot, error) in //Closure
            if let document = documentSnapshot { //Validate that document is not empty
                let attendees = document["attendees"] as? Int //Extract existing attendees value
                statsRef.updateData([
                    "attendees": attendees! + 1 //Increment attendees value by 1
                    ])
            }
        }
    }

    //Show snackbar on screen with JSON data
    func presentSnackbar(name: String, seats: String)
    {
        //Initialise snackbar message
        let message = MDCSnackbarMessage()

        //Define message text
        message.text = "Name: \(name), Seats: \(seats)"
        MDCSnackbarManager.show(message)
    }
    
    //Screen is tapped anywhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.captureSession.startRunning() //Resume capture session
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    { //Begin QR code detection
        
        //Validate detected objects
        if metadataObjects.count == 0 //No QR objects detected
        {
            print("No QR Code detected") //Console output for debugging
            return //Exit function
        }
        
        //QR Code detected...
        // Get the metadata object from the QR code
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        //Validate that the object returned is a QR code
        if [AVMetadataObject.ObjectType.qr].contains(metadataObj.type)
        {
            //Validate that the QR code contains a string value (i.e. not an empty string)...
            if metadataObj.stringValue != nil
            {
                print("QR Code detected") //Console output
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) //Vibrate phone
                self.captureSession.stopRunning() //End capture session
                //Decode QR
                presentQROutput(decodedMessage: metadataObj.stringValue!)
                
            }
        }
    }
    
}
