//
//  MapViewController.swift
//  SharedTogether
//
//  Created by kristianaatasi on 2/19/18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseAnalytics
import GeoFire

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    
    var ridesReference: DatabaseReference?
    var observeAdded: DatabaseHandle?
    var observeChanged: DatabaseHandle?
    var observeRemoved: DatabaseHandle?
    
    var rides: [String: Ride] = [:]
    var locationsDict: [String: CLLocation] = [:]
    
    var mapPins: [RideMKAnnotation] = []

    var currentLocation: CLLocation? {
        didSet {
            displayUserLocation()
        }
    }
    
    override func viewDidLoad() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        ridesReference = Database.database().reference().child(Constants.Rides.ROOT)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupLocationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager?.stopMonitoringSignificantLocationChanges()
    }
    

    fileprivate func setupLocationManager() {
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            return
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            locationManager?.requestAlwaysAuthorization()
        } else {
            locationManager?.startMonitoringSignificantLocationChanges()
        }
    }
    
    fileprivate func displayUserLocation() {
        guard let location = currentLocation else { return }
        
        let regionRadius: CLLocationDistance = 25000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    fileprivate func getRidesAroundCurrentLocation() {
        guard let currLocation = currentLocation else { return }

        if let ref = ridesReference {
            let geoFire = GeoFire(firebaseRef: ref)

            let regionRadius: CLLocationDistance = 25000
            let query = geoFire.query(at: currLocation, withRadius: regionRadius)
            
            query.observe(.keyEntered, with: { [weak self] (key, enteredLocation) in
                self?.locationsDict[key] = enteredLocation
                
                if let ride = self?.rides[key] {
                    
                    let pin = RideMKAnnotation(latitute: enteredLocation.coordinate.latitude, longitude: enteredLocation.coordinate.longitude, title: ride.destination, subtitle: ride.from)
                    self?.mapPins.append(pin)
                }
            })
            query.observeReady { [weak self] in
                if let pins = self?.mapPins {
                    self?.mapView.addAnnotations(pins)
                }
            }
        }
    }
    
    fileprivate func observeDataBaseChanges() {
        if let ref = ridesReference {
            observeAdded = ref.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                if let dictionary = snapshot.value as? NSDictionary {
                    let ride = Ride(dictionary: dictionary, id: snapshot.key)
                    
                    self?.rides[snapshot.key] = ride
                }
            })
            
            observeChanged = ref.observe(.childChanged, with: { [weak self] (snapshot) -> Void in
                if let dictionary = snapshot.value as? NSDictionary {
                    let ride = Ride(dictionary: dictionary, id: snapshot.key)
                    
                    self?.rides.updateValue(ride, forKey: snapshot.key)
                }
            })
            
            observeRemoved = ref.observe(.childRemoved, with: { [weak self] (snapshot) -> Void in

                self?.rides.removeValue(forKey: snapshot.key)
            })
            
        }
    }

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        
        if lastLocation.timestamp.timeIntervalSinceNow < 5.0 {
            currentLocation = lastLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            locationManager?.stopMonitoringSignificantLocationChanges()
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager?.startMonitoringSignificantLocationChanges()
        }
    }
}
