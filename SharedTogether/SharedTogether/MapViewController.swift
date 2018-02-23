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
    
    fileprivate static let radius: CLLocationDistance = 25000
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    var locationManager: CLLocationManager?
    
    fileprivate var ridesReference: DatabaseReference?
    fileprivate var observeAdded: DatabaseHandle?
    fileprivate var observeChanged: DatabaseHandle?
    fileprivate var observeRemoved: DatabaseHandle?

    fileprivate var locationsReference: DatabaseReference?
    
    fileprivate var rides: [String: Ride] = [:]
    fileprivate var locationsDict: [String: CLLocation] = [:]
    
    fileprivate var mapPins: [RideMKAnnotation] = []
    fileprivate var removedMapPins: [RideMKAnnotation] = []
    
    var currentLocation: CLLocation? {
        didSet {
            displayUserLocation()
            getRidesAroundCurrentLocation()
        }
    }
    
    var dateFormatter: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM, HH:mm"
            return dateFormatter
        }
    }
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.pausesLocationUpdatesAutomatically = true
        
        locationsReference = Database.database().reference()
        ridesReference = Database.database().reference().child(Constants.Rides.ROOT)
        
        getJoinedRides()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeDataBaseChanges()
        setupLocationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager?.stopMonitoringSignificantLocationChanges()
    }

    // MARK: - Private
    
    fileprivate func setupLocationManager() {
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            return
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            // TODO: make it to work with when in-use auth
            locationManager?.requestAlwaysAuthorization()
        } else {
            locationManager?.startMonitoringSignificantLocationChanges()
        }
    }
    
    fileprivate func displayUserLocation() {
        guard let location = currentLocation else { return }
        
        let regionRadius: CLLocationDistance = MapViewController.radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    fileprivate func getRidesAroundCurrentLocation() {
        guard let currLocation = currentLocation else { return }

        if let ref = locationsReference {
            let geoFire = GeoFire(firebaseRef: ref)

            let region = MKCoordinateRegionMakeWithDistance(currLocation.coordinate, MapViewController.radius, MapViewController.radius)
            let query = geoFire.query(with: region)

            query.observe(.keyEntered, with: { [weak self] (key, enteredLocation) in
                self?.locationsDict[key] = enteredLocation
                
                if let ride = self?.rides[key] {
                    
                    if let destination = ride.destination, let date = ride.dateOfRide {
                        let pin = RideMKAnnotation(latitute: enteredLocation.coordinate.latitude, longitude: enteredLocation.coordinate.longitude, title: "to: \(destination)", subtitle: self?.dateFormatter.string(from: date))
                        if !(self?.mapPins.contains(pin))! {
                            self?.mapPins.append(pin)
                        }
                    }
                }
            })
            query.observe(.keyExited, with: { [weak self] (key, location) in
                self?.locationsDict.removeValue(forKey: key)
                
                if let ride = self?.rides[key] {
                    
                    if let destination = ride.destination, let date = ride.dateOfRide {
                        let pin = RideMKAnnotation(latitute: location.coordinate.latitude, longitude: location.coordinate.longitude, title: "to: \(destination)", subtitle: self?.dateFormatter.string(from: date))
                        if (self?.mapPins.contains(pin))! {
                            if let index = self?.mapPins.index(of: pin) {
                                self?.mapPins.remove(at: index)
                                self?.removedMapPins.append(pin)
                            }
                        }
                    }
                }
            })
            
            query.observeReady { [weak self] in
                if let pins = self?.mapPins {
                    if let removed = self?.removedMapPins {
                        self?.mapView.removeAnnotations(removed)
                    }
                    self?.mapView.addAnnotations(pins)
                }
            }
        }
    }
    
    fileprivate func getJoinedRides() {
        if let ref = ridesReference {
            ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                print(snapshot)
                if snapshot.childrenCount > 0 {
                    guard let allSnaps = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    for child in allSnaps {
                        if let dictionary = child.value as? NSDictionary {
                            let ride = Ride(dictionary: dictionary, id: child.key)
                            
                            self?.rides[child.key] = ride
                        }
                    }
                }
            })
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

// MARK: - Extenstions

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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let annotationIdentifier = RideMKAnnotation.reuseIdentifier
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
            let infoButton = UIButton(type: .detailDisclosure)
            annotationView!.rightCalloutAccessoryView = infoButton
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "snowflake")
        annotationView!.image = pinImage
                
        return annotationView   
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation {
            if self.mapPins.contains(where: {$0 == annotation as! RideMKAnnotation}) {
                // TODO: handle selection
            }
        }
    }
}
