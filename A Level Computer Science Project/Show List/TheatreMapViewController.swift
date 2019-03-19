//  TheatreMapViewController.swift
//  Copyright © 2018 Seena Shafai. All rights reserved.

import UIKit
import CoreLocation
import MapKit

class TheatreMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
   
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
       
        
        let annotation = MKPointAnnotation() //Initialise the annotation object
        //Set coordinates of the annotation marker
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.494653, longitude: -0.610712)
        //Set the name of the annotation marker
        annotation.title = "Farrer Theatre"
        //Add the annotation to the map
        mapView.addAnnotation(annotation)
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        
    if CLLocationManager.locationServicesEnabled()
        //If location services are enabled
    {
        locationManager.delegate = self //Set the delegate
        print("location enabled") //Trace statement
        //Define accuracy of location pointer
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //Begin transmitting live location data
        locationManager.startUpdatingLocation()
    }

    //Get coordinates from location manager
    let sourceCoordinates = locationManager.location?.coordinate
    //Guard against case where no coordinates are given
    guard sourceCoordinates != nil else
        {   print("no coordinates given")
            return
        }
    //Define destination coordinates as Theatre coordinates
    let destCoordinates = CLLocationCoordinate2DMake(51.494653, -0.610712)

    //Define placemarks as Placemark items from coordinates
    let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinates!)
    let destPlaceMark = MKPlacemark(coordinate: destCoordinates)

    //Create destination and source items from placemarks.
    let sourceItem = MKMapItem(placemark: sourcePlaceMark)
    let destItem = MKMapItem(placemark: destPlaceMark)
        
        
    //Initialise the directions request
    let directionsRequest = MKDirections.Request()
    directionsRequest.source = sourceItem
    directionsRequest.destination = destItem
    directionsRequest.transportType = .automobile

    //Calculate directions for route
    let directions = MKDirections(request: directionsRequest)
    directions.calculate(completionHandler: {
        //Define response and error case in completion handler
        response, error in
        //Guard against error to prevent program crashing
        guard let response = response else {
            if error != nil {
                print("Calculation not completed")
            }
            return
        }
        //Extract route item from calculation
        let route = response.routes[0]
        //Add route line as an overlay
        self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        //Create rectangle from frame of route
        let rectFrame = route.polyline.boundingMapRect
        //Use rectangle frame to define region of map view
        self.mapView.setRegion(MKCoordinateRegion(rectFrame), animated: true)
    })
        
        
        // Do any additional setup after loading the view.
    }
 
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Define renderer for route line as overlay
        let renderer = MKPolylineRenderer(overlay: overlay)
        //Set route line UI attributes
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }
}

