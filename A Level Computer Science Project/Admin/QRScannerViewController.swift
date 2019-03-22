//  QRScannerViewController.swift
//  Copyright © 2018 Seena Shafai. All rights reserved.

import UIKit
import AVFoundation
import MaterialComponents.MaterialSnackbar
import FirebaseFirestore
import Alamofire.Swift

class QRScannerViewController: UIViewController {

    //MARK: - Properties
    //Database Config
    var db: Firestore!

    //Class Instances
    var captureSession = AVCaptureSession()
    var barcodeMethods = Barcode()

    //Global variables
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let APIEndpoint = "http://ftpkdist.serveo.net"
    var show: String?
    var dateIndex: String?

    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        //Validation: ensure that the rear camera actually exists
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
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
            print(error)
            return
        }
        
        //Initialise video preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        
        //Set video preview layer as sublayer
        view.layer.addSublayer(videoPreviewLayer!)
        
        //Start video capture session
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //End capture session as view is dismissed
        captureSession.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Begin capture session when view appears
        captureSession.startRunning()
    }
    
    func presentQROutput(decodedMessage: String)
    {
        var email: String?
        var seats: String?
        var name: String?
        //JSON Decoding
        let barcode = barcodeMethods.decodeJSONString(JSONString: decodedMessage)
        //Send HTTP GET request using new endpoint, default JSOn encoding and "application-json" content type header
        let endpoint = APIEndpoint + "/user_for_pass/\(String(describing: barcode!.pass_type_id))/\(String(describing: barcode!.serial_number))/\(String(describing: barcode!.authentication_token))"
        Alamofire.request(endpoint, method: HTTPMethod.get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { response in
            //Convert JSON result to dictionary with 'result.value'
            if let data = response.result.value as? [String: Any]
            {
                //Extract data from dictionary and assign it to local variables
                email = data["email"] as? String
                self.show = data["show"] as? String
                seats = data["seatRef"] as? String
                name = data["name"] as? String
                self.dateIndex = data["dateIndex"] as? String
                
            }
            //Set user attendance boolean to True
            self.userAttended(email: email!, show: self.show!)
            //Present snackbar with name and seat references
            self.presentSnackbar(seat: seats!, name: name!)
        }
        

    }
    //Update records for users who have attended
    func userAttended(email: String, show: String)
    {
        //Define location of attendance boolean in user's ticket
        let ticketRef = db.collection("users").document(email).collection("tickets").document(show)
        ticketRef.updateData([
            "attendance": true //set attendance boolean to true
            ])
        var attendees: Int!
        let strDateIndex = String(dateIndex!)
        let statsRef = db.collection("shows").document(show).collection(strDateIndex).document("statistics")
        statsRef.getDocument {(documentSnapshot, error) in
            if let document = documentSnapshot {
                attendees = document["attendees"] as? Int ?? 0
                statsRef.updateData([
                    "attendees": attendees + 1 //Add 1 to attendance
                    ])
            }
        }
    }

    //Show snackbar on screen with JSON data
    func presentSnackbar(seat: String, name: String)
    {
        //Initialise snackbar message
        let message = MDCSnackbarMessage()
        //Define message text
        message.text = "Name: \(name), Seat(s): \(seat)"
        //Show message
        MDCSnackbarManager.show(message)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.captureSession.startRunning() //Re-start capture session on screen select
    }
    
    

}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        // Check if the metadataObjects array is not nil and it contains at least one object (i.e. a code).
        if metadataObjects.count == 0
        {
            print("No QR Code detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if [AVMetadataObject.ObjectType.qr].contains(metadataObj.type)
        {
            if metadataObj.stringValue != nil
            {
                print("QR Code detected")
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) //Vibrate device
                self.captureSession.stopRunning() //Pause video feed
                presentQROutput(decodedMessage: metadataObj.stringValue!) //to HTTP GET
            }
        }
    }
    
}
