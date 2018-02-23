//
//  UserProfileViewController.swift
//  SharedTogether
//
//  Created by kristianaatasi on 2/21/18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserProfileViewController: BaseViewController {
    
    enum SectionType: Int {
        case rides
        case logout
    }
    
    var dateFormatter: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM, HH:mm"
            return dateFormatter
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhoneLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    fileprivate var user: User? {
        didSet {
            userNameLabel.text = user?.email
            userPhoneLabel.text = user?.phone
            userImageView.layer.cornerRadius = 60
            userImageView.backgroundColor = .gray
            
            tableView.reloadData()
        }
    }
    
    fileprivate var joinedRides: [String:Ride] = [:]
    fileprivate var ridesReference: DatabaseReference?
    
    fileprivate var observeAdded: DatabaseHandle?
    fileprivate var observeChanged: DatabaseHandle?
    fileprivate var observeRemoved: DatabaseHandle?
    
    fileprivate var rideJoinChanged: DatabaseHandle?

    // TODO: Make phone editable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        
        userImageView.clipsToBounds = true
        
        ridesReference = Database.database().reference().child(Constants.Rides.ROOT)
        
        getJoinedRides()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        user = Defaults.getLoggedUser()
        
        if user == nil {
            showLoginScreen()
        } else {
            observeDataBaseChanges()
        }
    }
    
    // MARK: - Private
    
    fileprivate func showLoginScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signInViewController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "SignInNavigationController") as! UINavigationController
        (signInViewController.viewControllers.first as! SigninViewController).delegate = self
        self.present(signInViewController, animated: true, completion: nil)
    }
    
    fileprivate func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            showAlert("Error", error.localizedDescription)
        }
        
        Defaults.removeLoggedUser()
        removeObservers()
        user = nil
        joinedRides = [:]
        
        showLoginScreen()
    }
    
    fileprivate func removeObservers() {
        if let addedHandle = observeAdded {
            ridesReference?.removeObserver(withHandle: addedHandle)
        }
        
        if let changedHandle = observeChanged {
            ridesReference?.removeObserver(withHandle: changedHandle)
        }
        
        if let removedHandle = observeRemoved {
            ridesReference?.removeObserver(withHandle: removedHandle)
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
                            
                            self?.joinedRides[child.key] = ride
                        }
                    }
                    
                    self?.tableView.reloadData()
                }
            })
        }
    }
    
    fileprivate func observeDataBaseChanges() {
        
        if let ref = ridesReference {
            observeAdded = ref.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                if let dictionary = snapshot.value as? NSDictionary {
                    let ride = Ride(dictionary: dictionary, id: snapshot.key)
                    if let rides = self?.user?.joinedRides, let correspondingRide = rides[snapshot.key], correspondingRide == true {
                        self?.joinedRides[snapshot.key] = ride
                        
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
            })
            
            observeChanged = ref.observe(.childChanged, with: { [weak self] (snapshot) -> Void in
                if let dictionary = snapshot.value as? NSDictionary {
                    let ride = Ride(dictionary: dictionary, id: snapshot.key)
                    
                    self?.joinedRides.updateValue(ride, forKey: snapshot.key)
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            })
            
            observeRemoved = ref.observe(.childRemoved, with: { [weak self] (snapshot) -> Void in
                
                self?.joinedRides.removeValue(forKey: snapshot.key)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
        }
        if let user = user {
            
            Database.database().reference()
                .child(Constants.Users.ROOT)
                .child(user.id)
                .child(Constants.Users.JOINED_RIDES).observe(.childChanged, with: { snapshot in
                    DispatchQueue.main.async {
                        self.user?.joinedRides?[snapshot.key] = snapshot.value as? Bool
                        Defaults.setLoggedUser(user: self.user!)
                        self.tableView.reloadData()
                    }
                })
        }
    }
}

extension UserProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let user = user, let joinedRides = user.joinedRides {
            let filteredIds = joinedRides.filter { $0.value == true }

            return filteredIds.count > 0 ? 2 : 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case SectionType.rides.rawValue:
            if let rides = user?.joinedRides {
                let filteredIds = rides.filter { $0.value == true }

                return filteredIds.count > 0 ? filteredIds.count : 1
            }
            return 0
        case SectionType.logout.rawValue:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let user = user, let joinedRides = user.joinedRides {
            if !joinedRides.isEmpty {
                if indexPath.section == SectionType.rides.rawValue {
                    let cell = tableView.dequeueReusableCell(withIdentifier: RideProfileTableViewCell.cellIdentifier, for: indexPath)
                    
                    let filteredIds = joinedRides.filter { $0.value == true }
                    
                    var rideIds: [String] = Array(filteredIds.keys)
                    
                    let rideId = rideIds[indexPath.item]
                    let rideForId = self.joinedRides[rideId]
                    
                    // sort: self?.joinedRides.keys.sorted(by: { $0 > $1 })
                    
                    var date: String = "---"
                    if let rideDate = rideForId?.dateOfRide {
                        date = dateFormatter.string(from: rideDate)
                    }
                    
                    (cell as! RideProfileTableViewCell).configure(resort: rideForId?.destination ?? "---", date: date)
                    cell.contentView.subviews.first?.layer.cornerRadius = 3.0
                    return cell
                }
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath)
        cell.contentView.subviews.first?.layer.cornerRadius = 3.0
        return cell
        
    }
}

extension UserProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let user = user, let rides = user.joinedRides, !rides.isEmpty {
            if indexPath.section == SectionType.rides.rawValue {
                
                let filteredIds = rides.filter { $0.value == true }
                
                var rideIds: [String] = Array(filteredIds.keys)
                
                let rideId = rideIds[indexPath.item]
                let rideForId = self.joinedRides[rideId]
                
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let rideViewController: RideDetailsViewController = storyboard.instantiateViewController(withIdentifier: "RideDetailsViewController") as! RideDetailsViewController
                rideViewController.ride = rideForId

                let navController = UINavigationController(rootViewController: rideViewController)
                let backItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                navController.navigationItem.backBarButtonItem = backItem
                
                self.present(navController, animated: true, completion: nil)
                
                return
            }
        }
        
        logout()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let user = user, let rides = user.joinedRides, !rides.isEmpty {
            if section == SectionType.rides.rawValue {
                return "My Rides"
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red: 86/255, green: 190/255, blue: 197/255, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let user = user, let rides = user.joinedRides, !rides.isEmpty {
            if section == SectionType.rides.rawValue {
                return 40.0
            }
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }

}

extension UserProfileViewController: SigninViewControllerDelegate {
    func didSignInSuccessfully() {
        getJoinedRides()
    }
}
