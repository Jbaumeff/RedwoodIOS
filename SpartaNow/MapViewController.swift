//
//  ViewController.swift
//  SpartaNow
//
//  Created by Jeffry Baum on 3/27/15.
//  Copyright (c) 2015 Jeffry Baum. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate  {

    @IBOutlet weak var viewMap: MKMapView!
    var locationManager: CLLocationManager!
    var zoomToLocation = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomToLocation = true;
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        viewMap.showsUserLocation = true
        
        // Status of user is variable that speaks directly to (in this case) authorization status
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.NotDetermined || status == CLAuthorizationStatus.Denied {
            locationManager.requestWhenInUseAuthorization()
        } else if status != CLAuthorizationStatus.Denied {

            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        if zoomToLocation {
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.viewMap.setRegion(region, animated: true)
            zoomToLocation = false
        }
    }
    
    // If the status changes to authorize when in use or always authorize
    // then start updating the location, if not don't do anything.
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    // If the location failed when trying to get users location execute this function
    func  locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: \(error)")
    }
}

