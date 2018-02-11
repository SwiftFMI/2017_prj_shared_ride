//
//  RideDetailsViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 1.02.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RideDetailsViewController: BaseViewController {
    
    @IBOutlet weak var buttonOpenChat: UIButton!
    @IBOutlet weak var buttonJoinRide: UIButton!
    @IBOutlet weak var buttonLeaveRide: UIButton!
    
    var ride: Ride?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = Defaults.getLoggedUser() else { return }
        guard let ride = ride else { return }
        
        
        
        if let rideId = ride.id, let userJoinedRudes = user.joinedRides {
            if userJoinedRudes[rideId] ?? false {
                buttonJoinRide.isEnabled = false
                buttonLeaveRide.isEnabled = true
                buttonOpenChat.isEnabled = true
            } else {
                buttonJoinRide.isEnabled = true
                buttonLeaveRide.isEnabled = false
                buttonOpenChat.isEnabled = false
            }
        }
        
        if let rideOwner = ride.ownerId {
            if rideOwner == user.id {
                buttonLeaveRide.isEnabled = false
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let ride = sender as? Ride, let chatVc = segue.destination as? ChatViewController {
            chatVc.groupId = ride.groupChatId
        }
    }
    
    @IBAction func openChat(_ sender: UIButton) {
        guard let ride = ride else { return }
        performSegue(withIdentifier: Constants.Segues.DetailsToChat, sender: ride)
    }
    
    @IBAction func onJoinRideTab(_ sender: UIButton) {
        guard var user = Defaults.getLoggedUser() else { return }
        guard let ride = ride else { return }
        
        guard let rideId = ride.id else { return }
//        guard let rideFreePlaces = ride.freePlaces else { return }
        
        let groupChatRef = Database.database().reference()
            .child(Constants.RidesGroupChat.ROOT)
            .child(ride.groupChatId!)
            .child(Constants.RidesGroupChat.CHAT_MEMBERS)
        
        groupChatRef.updateChildValues(["\(user.id)": user.name])
        
        Database.database().reference()
            .child(Constants.Users.ROOT)
            .child(user.id)
            .child(Constants.Users.JOINED_RIDES)
            .updateChildValues(["\(rideId)": true], withCompletionBlock: { [weak self] (error, snapshot) in
                
                //ask what happends with memmory here
                if error == nil {
                    user.joinedRides?["\(rideId)"] = true
                    Defaults.setLoggedUser(user: user)
                    
                    self?.buttonOpenChat.isEnabled = true
                    self?.buttonLeaveRide.isEnabled = true
                    self?.buttonJoinRide.isEnabled = false
                }
            })
        
        //TODO handle ride free places decreasing count
    }
    
    @IBAction func onLeaveRideTab(_ sender: Any) {
    }
    
}
