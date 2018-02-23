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
import KVNProgress

class RideDetailsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var availableSeatsLabel: UILabel!
    
    var currentCellIdentifiers: [String] = []
    
    var ride: Ride?
    var user: User?
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDateSource()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if self.presentingViewController != nil {
            let backItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backTapped(_:)))
            self.navigationItem.leftBarButtonItem = backItem
        }
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 86/255, green: 190/255, blue: 197/255, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureHeader()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let ride = sender as? Ride, let chatVc = segue.destination as? ChatViewController {
            chatVc.groupId = ride.groupChatId
        }
    }
    
    // MARK: - Actions
    
    @objc func backTapped(_ sender: UIBarButtonItem) {
        if KVNProgress.isVisible() {
            KVNProgress.dismiss()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK : - Private
    
    fileprivate func setupDateSource() {
        guard let user = Defaults.getLoggedUser() else { return }
        guard let ride = ride else { return }
        
        self.user = user
        
        currentCellIdentifiers = []
        
        if let rideId = ride.rideId, let userJoinedRides = user.joinedRides,
            let joinedRide = userJoinedRides[rideId], joinedRide {
            currentCellIdentifiers.append("RideDetailsLeave")
            currentCellIdentifiers.append("RideDetailsChat")
            currentCellIdentifiers.append("RideDetailsCall")
        } else {
            currentCellIdentifiers.append("RideDetailsJoin")
        }
    
        
        if let rideOwner = ride.ownerId {
            if rideOwner == user.id {
                currentCellIdentifiers.append("RideDetailsDelete")
                currentCellIdentifiers.remove(at: 0)
                if currentCellIdentifiers.count > 1 {
                    currentCellIdentifiers.remove(at: 1)
                }
            }
        }
    }
    
    fileprivate func configureHeader() {
        let rideFrom = ride?.from ?? ""
        let rideTo = ride?.destination ?? ""
        let freePlaces = ride?.freePlaces ?? ""
        let date = Utils.dateFromDate(date: ride?.dateOfRide)
        let time = Utils.timeFromDate(date: ride?.dateOfRide)
        configureHeader(fromLocation: rideFrom, destination: rideTo, availablePlaces: freePlaces, time: time, date: date)
    }
    
    fileprivate func call() {
        if let phone = user?.phone, let url = URL(string: "tel://\(phone)"),
        UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    fileprivate func openChat() {
        guard let ride = ride else { return }
        performSegue(withIdentifier: Constants.Segues.DetailsToChat, sender: ride)
    }
    
    fileprivate func joinRide() {
        guard var user = Defaults.getLoggedUser() else { return }
        guard let ride = ride else { return }

        guard let rideId = ride.rideId else { return }
        guard let rideFreePlaces = ride.freePlaces else { return }
        
        KVNProgress.show(withStatus: "Joining ride...")
        
        var freePlaces = Int(rideFreePlaces)!
        if freePlaces > 0 {
            freePlaces -= 1
        }

        self.ride?.freePlaces = String(freePlaces)
        
        guard let rideOwnerId = ride.ownerId else { return }
        guard let rideChatId = ride.groupChatId else { return }
        
        let parameters: Parameters = [
            "rideId": rideId,
            "rideOwnerId": rideOwnerId,
            "joinUserId": user.id,
            "rideChatId": rideChatId
        ]
        
        guard let url = URL(string: "https://us-central1-shared-together.cloudfunctions.net/api/joinRide") else { return }
        
        Alamofire
            .request(url.absoluteString, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .response { [weak self] response in
                
                KVNProgress.dismiss()
                
                if  response.response?.statusCode == 200  {
                    
                    user.joinedRides?["\(rideId)"] = true
                    Defaults.setLoggedUser(user: user)
                    
                    self?.setupDateSource()
                    self?.configureHeader()
                    self?.tableView.reloadData()
                }
                
                print("Response: \(String(describing: String(data: response.data ?? Data(), encoding: .utf8)))")
        }
    }
    
    fileprivate func leaveRide() {
        guard let rideId = ride?.rideId else { return }
        guard let rideOwnerId = ride?.ownerId else { return }
        guard var user = Defaults.getLoggedUser() else { return }
        guard let rideChatId = ride?.groupChatId else { return }
        guard let rideFreePlaces = ride?.freePlaces else { return }
        
        KVNProgress.show(withStatus: "Leaving ride...")

        Database.database().reference()
            .child(Constants.Users.ROOT)
            .child(user.id)
            .child(Constants.Users.JOINED_RIDES)
            .updateChildValues(["\(rideId)": false], withCompletionBlock: { (error, snapshot) in
            })

        var freePlaces = Int(rideFreePlaces)!
        freePlaces += 1
        self.ride?.freePlaces = String(freePlaces)

        let parameters: Parameters = [
            "rideId": rideId,
            "rideOwnerId": rideOwnerId,
            "leaveUserId": user.id,
            "rideChatId": rideChatId
        ]
        
        guard let url = URL(string: "https://us-central1-shared-together.cloudfunctions.net/api/leaveRide") else { return }
        
        Alamofire
            .request(url.absoluteString, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .response { [weak self] response in
                
                KVNProgress.dismiss()
                
                if  response.response?.statusCode == 200  {
                    
                    user.joinedRides?["\(rideId)"] = false
                    Defaults.setLoggedUser(user: user)

                    self?.setupDateSource()
                    self?.configureHeader()
                    self?.tableView.reloadData()
                }
                
                print("Response: \(String(describing: String(data: response.data ?? Data(), encoding: .utf8)))")
        }
    }
    
    fileprivate func deleteRide() {
        guard let rideId = ride?.rideId else { return }
        guard var user = Defaults.getLoggedUser() else { return }
        guard let rideChatId = ride?.groupChatId else { return }
        
        KVNProgress.show(withStatus: "Deleting ride...")
        
        let parameters: Parameters = [
            "rideId": rideId,
            "userId": user.id,
            "rideChatId": rideChatId
        ]
        
        guard let url = URL(string: "https://us-central1-shared-together.cloudfunctions.net/api/deleteRide") else { return }
        
        Alamofire
            .request(url.absoluteString, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .response { response in
                
                KVNProgress.dismiss()
                
                if  response.response?.statusCode == 200  {
                    
                    user.joinedRides?["\(rideId)"] = false
                    Defaults.setLoggedUser(user: user)
                    self.navigationController?.popViewController(animated: true)
                }
                
                print("Response: \(String(describing: String(data: response.data ?? Data(), encoding: .utf8)))")
        }
    }
    
    fileprivate func configureHeader(fromLocation: String?, destination: String?, availablePlaces: String?, time: String?, date: String?) {
        fromLabel.text = fromLocation
        destinationLabel.text = destination
        availableSeatsLabel.text = availablePlaces
        timeLabel.text = time
        dateLabel.text = date
    }
}

extension RideDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentCellIdentifiers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCellIdentifiers[indexPath.item], for: indexPath)
        
        cell.contentView.subviews.first?.layer.cornerRadius = 3.0
        return cell
    }
}

extension RideDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch currentCellIdentifiers[indexPath.item] {
        case "RideDetailsJoin":
            joinRide()
            break
        case "RideDetailsLeave":
            leaveRide()
            break
        case "RideDetailsChat":
            openChat()
            break
        case "RideDetailsCall":
            call()
            break
        case "RideDetailsDelete":
            let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this ride?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { [weak self] action in
                self?.deleteRide()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }
    
}
