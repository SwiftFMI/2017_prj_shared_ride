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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        let ref = Database.database().reference()
        let rideGroupChatRef = createGroupChat(dbRef: ref, freePlaces: freePlacesNumber, user: user)
        
        let newRide =
            [Constants.Rides.FROM: from,
             Constants.Rides.DESTINATION: destination,
             Constants.Rides.FREEPLACES: freePlaces,
             Constants.Rides.DRIVER: user.name,
             Constants.Rides.GROUP_CHAT_ID: rideGroupChatRef.key,
             Constants.Rides.OWNER_ID: user.id]
        
        let newRideRef = ref.child(Constants.Rides.ROOT).childByAutoId()
        newRideRef.setValue(newRide)
        
        user.joinedRides?["\(newRideRef.key)"] = true
        
        Defaults.setLoggedUser(user: user)
        
        ref
            .child(Constants.Users.ROOT)
            .child(user.id)
            .child(Constants.Users.JOINED_RIDES)
            .updateChildValues(["\(newRideRef.key)": true])
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
