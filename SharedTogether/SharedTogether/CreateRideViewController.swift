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

class CreateRideViewController: BaseViewController {
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var freePlacesTextField: UITextField!
    @IBOutlet weak var dateOfRide: UITextField!
    
    let picker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(pickerDonePressed))
        toolbar.setItems([doneButton], animated: false)
        
        dateOfRide.inputAccessoryView = toolbar
        dateOfRide.inputView = picker
        dateOfRide.text = Utils.formatDate(date: picker.date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        picker.date = Date()
        dateOfRide.text = Utils.formatDate(date: picker.date)
    }
    
    @objc func pickerDonePressed() {
        dateOfRide.text = Utils.formatDate(date: picker.date)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createRide(_ sender: UIButton) {
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
            //TODO: display error or handle case
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
        
        user.joinedRides?["\(newRideRef.key)"] = true
        
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
        
        tabBarController?.selectedIndex = 0
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
}
