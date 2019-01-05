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


class QRScannerViewController: UIViewController {

    //MARK: - Properties
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var globalMessage = ""
    var barcodeMethods = Barcode()
    let APIEndpoint = "http://192.168.1.25:6789"
    var returnedUser: PKUser?

    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
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
        if presentedViewController != nil
        {
            return
        }
        
        //JSON Decoding
        let barcode = barcodeMethods.decodeJSONString(JSONString: decodedMessage)
        
        barcodeMethods.sendJSONRequest(withMethod: "GET", APIEndpoint: APIEndpoint, path: "/user_for_pass/\(String(describing: barcode!.pass_type_id))/\(String(describing: barcode!.serial_number))/\(String(describing: barcode!.authentication_token))", formFields: nil) { user, error in
            guard user != nil else {
                print(error, "error")
                return
            }
            print(user, "user")
            self.returnedUser = user
            
            //Flash a success message from PKHud
            HUD.flash(.success)
            
            //Present snackbar with QR Code data
            let message = MDCSnackbarMessage()
            let action = MDCSnackbarMessageAction()
            let actionHandler = {() in
                self.performSegue(withIdentifier: "toQRDetails", sender: nil)
            }
            action.handler = actionHandler
            action.title = "More"
            message.action = action
            message.text = "Name: \(self.returnedUser!.name), Seat: \(self.returnedUser!.email)"
            MDCSnackbarManager.show(message)
        }
        
        print(returnedUser?.email, "email")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQRDetails"
        {
            var destVC = segue.destination as! QRDetailsViewController
            destVC.passVar = globalMessage
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.captureSession.startRunning()
    }
    
    

}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        var decodedMessage: String!
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
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.captureSession.stopRunning()
                decodedMessage = metadataObj.stringValue!
                globalMessage = metadataObj.stringValue!
                presentQROutput(decodedMessage: decodedMessage)
            }
        }
    }
    
}
