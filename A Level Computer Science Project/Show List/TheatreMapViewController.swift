//
//  TheatreMapViewController.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 03/12/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class TheatreMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.494653, longitude: -0.610712)
        mapView.addAnnotation(annotation)
        annotation.title = "Farrer Theatre"
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            print("location enabled")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        let sourceCoordinates = locationManager.location?.coordinate
        guard sourceCoordinates != nil else {print("nil source"); return}
        let destCoordinates = CLLocationCoordinate2DMake(51.494653, -0.610712)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinates!)
        let destPlaceMark = MKPlacemark(coordinate: destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destPlaceMark)
        
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceItem
        directionsRequest.destination = destItem
        directionsRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate(completionHandler: {
            response, error in
            guard let response = response else {
                if let error = error {
                    print("Something Went Wrong")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let rekt = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rekt), animated: true)
            
        })
        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
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
