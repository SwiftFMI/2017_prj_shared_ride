//
//  RideDetailsViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 1.02.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire

class RideDetailsViewController: BaseViewController {
    
    @IBOutlet weak var buttonOpenChat: UIButton!
    @IBOutlet weak var buttonJoinRide: UIButton!
    @IBOutlet weak var buttonLeaveRide: UIButton!
    @IBOutlet weak var buttonCancelDeleteRide: UIButton!
    
    var ride: Ride?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = Defaults.getLoggedUser() else { return }
        guard let ride = ride else { return }
        
        
        
        if let rideId = ride.rideId, let userJoinedRudes = user.joinedRides {
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
                buttonCancelDeleteRide.isEnabled = true
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
//        guard var user = Defaults.getLoggedUser() else { return }
//        guard let ride = ride else { return }
//
//        guard let rideId = ride.id else { return }
////        guard let rideFreePlaces = ride.freePlaces else { return }
//
//        let groupChatRef = Database.database().reference()
//            .child(Constants.RidesGroupChat.ROOT)
//            .child(ride.groupChatId!)
//            .child(Constants.RidesGroupChat.CHAT_MEMBERS)
//
//        groupChatRef.updateChildValues(["\(user.id)": user.name])
//
//        Database.database().reference()
//            .child(Constants.Users.ROOT)
//            .child(user.id)
//            .child(Constants.Users.JOINED_RIDES)
//            .updateChildValues(["\(rideId)": true], withCompletionBlock: { [weak self] (error, snapshot) in
//
//                //ask what happends with memmory here
//                if error == nil {
//                    user.joinedRides?["\(rideId)"] = true
//                    Defaults.setLoggedUser(user: user)
//
//                    self?.buttonOpenChat.isEnabled = true
//                    self?.buttonLeaveRide.isEnabled = true
//                    self?.buttonJoinRide.isEnabled = false
//                }
//            })
        
        //TODO handle ride free places decreasing count
        
        guard let rideId = ride?.rideId else { return }
        guard let rideOwnerId = ride?.ownerId else { return }
        guard var user = Defaults.getLoggedUser() else { return }
        guard let rideChatId = ride?.groupChatId else { return }
        
        let parameters: Parameters = [
            "rideId": rideId,
            "rideOwnerId": rideOwnerId,
            "joinUserId": user.id,
            "rideChatId": rideChatId
        ]
        let url = URL(string: "https://us-central1-shared-together.cloudfunctions.net/api/joinRide")!
        
        Alamofire
            .request(url.absoluteString, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .response { response in
                if  response.response?.statusCode == 200  {
                    //TODO hide loader and update current user profile
                    
                    user.joinedRides?["\(rideId)"] = true
                    Defaults.setLoggedUser(user: user)

                    self.buttonOpenChat.isEnabled = true
                    self.buttonLeaveRide.isEnabled = true
                    self.buttonJoinRide.isEnabled = false
                }
                
                print("Response: \(String(describing: String(data: response.data ?? Data(), encoding: .utf8)))")
        }
    }
    
    @IBAction func onLeaveRideTab(_ sender: Any) {
        guard let rideId = ride?.rideId else { return }
        guard let rideOwnerId = ride?.ownerId else { return }
        guard var user = Defaults.getLoggedUser() else { return }
        

        let parameters: Parameters = [
            "rideId": rideId,
            "rideOwnerId": rideOwnerId,
            "leaveUserId": user.id
        ]
        let url = URL(string: "https://us-central1-shared-together.cloudfunctions.net/api/leaveRide")!
        
        Alamofire
            .request(url.absoluteString, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .response { response in
                if  response.response?.statusCode == 200  {
                    //TODO hide loader and update current user profile
                    
                    user.joinedRides?["\(rideId)"] = true
                    Defaults.setLoggedUser(user: user)
                    
                    self.buttonOpenChat.isEnabled = false
                    self.buttonLeaveRide.isEnabled = false
                    self.buttonJoinRide.isEnabled = true
                }
                
                print("Response: \(String(describing: String(data: response.data ?? Data(), encoding: .utf8)))")
        }
    }
    
    @IBAction func cancelDeleteRide(_ sender: UIButton) {
    }
}
