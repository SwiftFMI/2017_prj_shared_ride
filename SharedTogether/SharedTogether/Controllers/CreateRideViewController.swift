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
        
        let ref = Database.database().reference()
        let rideGroupChatRef = createGroupChat(dbRef: ref)
        
        let driver = UserDefaults.standard.string(forKey: Constants.UserDefaults.USER) ?? "test"
        
        let newRide =
            [Constants.Rides.FROM: from,
             Constants.Rides.DESTINATION: destination,
             Constants.Rides.FREEPLACES: freePlaces,
             Constants.Rides.DRIVER: driver,
             Constants.Rides.GROUP_CHAT_ID: rideGroupChatRef.key]
        
        let newRideRef = ref.child(Constants.Rides.ROOT).childByAutoId()
        newRideRef.setValue(newRide)
    }
    
    func createGroupChat(dbRef: DatabaseReference) -> DatabaseReference {
//        let user = UserDefaults.standard.object(forKey: Constants.UserDefaults.USER) as! User
        
        let userId = Auth.auth().currentUser?.uid ?? "0"
        let name = UserDefaults.standard.string(forKey: Constants.UserDefaults.USER) ?? ""
        
        //userId: name
        let newGroupChat: [String:String] = [userId: name]
        
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
