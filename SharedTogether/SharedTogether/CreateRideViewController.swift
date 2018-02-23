//
//  CreateRideViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 17.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import GeoFire
import CoreLocation

class CreateRideViewController: BaseViewController {
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var freePlacesTextField: UITextField!
    @IBOutlet weak var dateOfRide: UITextField!
    
    @IBOutlet weak var locationSwitch: UISwitch!
    
    var currentUserLocation: CLLocation?
    var locationManager: CLLocationManager?
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    let picker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(pickerDonePressed))
        doneButton.tintColor = UIColor(red: 86/255, green: 190/255, blue: 197/255, alpha: 1.0)
        toolbar.setItems([doneButton], animated: false)
        
        dateOfRide.inputAccessoryView = toolbar
        dateOfRide.inputView = picker
        
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        locationSwitch.addTarget(self, action: #selector(locationSwitchChanged), for: .valueChanged)
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.pausesLocationUpdatesAutomatically = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.view.frame.width > self.view.frame.height {
            self.topConstraint.constant = 16.0
        } else {
            self.topConstraint.constant = 32.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createRide(_ sender: UIButton) {
        
        guard let isAnonymous = Auth.auth().currentUser?.isAnonymous else { return }
        
        if isAnonymous {
            showAlert("Error", "You have to log in first")
            return
        }
        
        guard let from = fromTextField.text else {
            return
        }
        
        guard let destination = destinationTextField.text else {
            return
        }
        
        guard let freePlaces = freePlacesTextField.text else {
            return
        }
        
        if from.isEmpty || destination.isEmpty || freePlaces.isEmpty {
            showAlert("Error", "Please fill all fields")
            return
        }
        
        guard let freePlacesNumber = Int(freePlaces) else {
            //TODO: display error or handle case
            return
        }
        
        if freePlacesNumber < 1 {
            showAlert("Error", "You must have at least 1 free place")
            return
        }
        
        guard var user = Defaults.getLoggedUser() else {
            return
        }
        
        if picker.date <= Date() {
            showAlert("Error", "You start trip date should be in the future")
            return
        }
        
        let startDate = String(Int64(picker.date.timeIntervalSince1970))
        let creationDate = String(Int64(Date().timeIntervalSince1970))
        
        let ref = Database.database().reference()
        let rideGroupChatRef = createGroupChat(dbRef: ref, freePlaces: freePlacesNumber, user: user)
        
        let newRide =
            [Constants.Rides.FROM: from,
             Constants.Rides.DESTINATION: destination,
             Constants.Rides.FREEPLACES: freePlaces,
             Constants.Rides.DRIVER: user.name,
             Constants.Rides.GROUP_CHAT_ID: rideGroupChatRef.key,
             Constants.Rides.OWNER_ID: user.id,
             Constants.Rides.START_RIDE_DATE: startDate,
             Constants.Rides.CREATION_DATE: creationDate]
        
        let newRideRef = ref.child(Constants.Rides.ROOT).childByAutoId()
        newRideRef.setValue(newRide)
        
        if locationSwitch.isOn {
            let geoFire = GeoFire(firebaseRef: ref)
            if let location = currentUserLocation {
                geoFire.setLocation(location, forKey: newRideRef.key)
            }
        }
        
        user.joinedRides?[newRideRef.key] = true
        
        Defaults.setLoggedUser(user: user)
        
        ref
            .child(Constants.ChatNotifications.ROOT)
            .child(rideGroupChatRef.key)
            .updateChildValues([user.id: true])
        
        ref
            .child(Constants.Users.ROOT)
            .child(user.id)
            .child(Constants.Users.JOINED_RIDES)
            .updateChildValues([newRideRef.key: true])
        
        fromTextField.text = ""
        destinationTextField.text = ""
        freePlacesTextField.text = ""
        dateOfRide.text = ""
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func createGroupChat(dbRef: DatabaseReference, freePlaces: Int, user: User) -> DatabaseReference {
//        let user = UserDefaults.standard.object(forKey: Constants.UserDefaults.USER) as! User
        
        let userId = user.id
        let name = user.name
        
        //userId: name
        var newGroupChat: [String:String] = [String:String]()
        newGroupChat[userId] = name
        
        // userId : message
        let messagess = [String:String]()
        
        let newRideGroup =
            [Constants.RidesGroupChat.CHAT_MEMBERS: newGroupChat, Constants.RidesGroupChat.MESSAGESS: messagess]
        
        let newRideGroupRef = dbRef.child(Constants.RidesGroupChat.ROOT).childByAutoId()
        
        newRideGroupRef.setValue(newRideGroup)
        
        return newRideGroupRef
    }
    
    @objc func dateChanged(sender: UIDatePicker) {
        
        self.dateOfRide.text = Utils.formatDate(date: sender.date)
    }
    
    @objc func pickerDonePressed() {
        dateOfRide.text = Utils.formatDate(date: picker.date)
        self.view.endEditing(true)
    }
    
    @objc func locationSwitchChanged(sender: UISwitch) {
        
        if sender.isOn {
            if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                
                locationManager?.startUpdatingLocation()
            } else {
                locationManager?.requestWhenInUseAuthorization()
            }
        } else {
            locationManager?.stopUpdatingLocation()
        }
    }
        
    @objc func keyboardWillShow(_ notification: NSNotification) {

        UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
            self?.topConstraint.constant = 16
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {

        UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
            self?.topConstraint.constant = 32
            self?.view.layoutIfNeeded()
        })
    }
}

extension CreateRideViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentUserLocation == nil {
            let lastLocation = locations.last!
            
            if lastLocation.timestamp.timeIntervalSinceNow < 5.0 {
                currentUserLocation = lastLocation
            }
        }
        locationManager?.stopUpdatingLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            locationManager?.stopUpdatingLocation()
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
}
