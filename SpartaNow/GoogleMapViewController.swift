//
//  GoogleMapViewController.swift
//  SpartaNow
//
//  Created by Jeffry Baum on 3/28/15.
//  Copyright (c) 2015 Jeffry Baum. All rights reserved.
//

import UIKit

class GoogleMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var locationManager: CLLocationManager!
    var zoomToLocation = false
    var mapView: GMSMapView!
    var address = [String]()
    var userLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    var isMarkerDown = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomToLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        mapView = GMSMapView()
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        self.view = mapView
        
        
        if status == CLAuthorizationStatus.NotDetermined || status == CLAuthorizationStatus.Denied {
            locationManager.requestWhenInUseAuthorization()
        } else if status != CLAuthorizationStatus.Denied {
            mapView.myLocationEnabled = true
            locationManager.startUpdatingLocation()
        }

    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        
        userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        if zoomToLocation {
            self.mapView.camera = GMSCameraPosition.cameraWithLatitude(userLocation.latitude, longitude: userLocation.longitude, zoom: 16)
            zoomToLocation = false
        }
    }
    
    // If the status changes to authorize when in use or always authorize
    // then start updating the location, if not don't do anything.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways {
            mapView.myLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    // If the location failed when trying to get users location execute this function
    func  locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: \(error)")
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        var position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        var marker = GMSMarker(position: position)
        reverseGeocodeCoordinate(coordinate)
//        if address.count > 1 {
//            marker.title = address[0]
//            marker.snippet = address[1]
//        }
        destinationLocation = coordinate
        isMarkerDown = true
        marker.map = mapView

    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        isMarkerDown = false
        mapView.clear()
    }
    
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            // 3
            infoView.addressOneLabel.text = address[0]
            infoView.addressTwoLabel.text = address[1]
            
            return infoView
        } else {
            return nil
        }
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                self.address = address.lines as [String]
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "ToResults" {
                let destination = segue.destinationViewController as WalkBusViewController
                destination.userLocation = userLocation
                destination.destinationLocation = destinationLocation
                destination.startConnection()
                
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if let name = identifier {
            if name == "ToResults" && !isMarkerDown {
                let alert = UIAlertView()
                alert.title = "No Destination Set"
                alert.message = "Please set a destination marker"
                alert.addButtonWithTitle("Ok")
                alert.show()
                return false
            }
        }
        return true
    }
    
    

}
