//
//  HomeViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 8.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

private let reuseIdentifier = "RidesCell"

class HomeViewController: BaseViewController {
//    present pop Over VC
    

    @IBOutlet weak var ridesTableView: UITableView!
    
    var ridesReference: DatabaseReference?
    var rides: [Ride] = []
    var user = Defaults.getLoggedUser()
    var observeAdded: DatabaseHandle?
    var observeChanged: DatabaseHandle?
    var observeRemoved: DatabaseHandle?
    var startRideRef: String?
    
    override func viewWillAppear(_ animated: Bool) {
        user = Defaults.getLoggedUser()
        
        if let ref = ridesReference {
//            observeAdded = ref.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
//                if let dictionary = snapshot.value as? NSDictionary {
//                    let ride = Ride(dictionary: dictionary, id: snapshot.key)
//
//                    self?.rides.append(ride)
//                    self?.ridesTableView.reloadData()
//                }
//            })
            
            observeChanged = ref.observe(.childChanged, with: { [weak self] (snapshot) -> Void in
                if let dictionary = snapshot.value as? NSDictionary {
                    let ride = Ride(dictionary: dictionary, id: snapshot.key)

                    if let updateIndex = self?.rides.index(where: {$0 == ride}) {
                        self?.rides[updateIndex] = ride
                        self?.ridesTableView.reloadRows(at: [IndexPath(row: updateIndex, section: 0)], with: .none)
                    }
                }
            })

            observeRemoved = ref.observe(.childRemoved, with: { [weak self] (snapshot) -> Void in
                if let dictionary = snapshot.value as? NSDictionary {
                    let ride = Ride(dictionary: dictionary, id: snapshot.key)

                    if let removedIndex = self?.rides.index(where: {$0 == ride}) {
                        self?.rides.remove(at: removedIndex)
                        self?.ridesTableView.deleteRows(at: [IndexPath(row: removedIndex, section: 0)], with: .automatic)
                    }
                }
            })
            
        }
    }
    
    func loadRides() {
        //TODO: check if remove observing of single event is needed probably not
        //TODO: detect pull to refresh and load more at bottom
        //TODO: order by date
        guard let ridesReference = ridesReference?.queryOrderedByKey() else { return }
        
        if let startRideRef = startRideRef {
            ridesReference
                .queryStarting(atValue: startRideRef)
                .queryLimited(toLast: 20)
                .observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                    print(snapshot)
                    if snapshot.childrenCount > 0 {
                        guard let lastChilden = snapshot.children.allObjects.last as? DataSnapshot else { return }
                        guard let allSnaps = snapshot.children.allObjects as? [DataSnapshot] else { return }
                        
                        for child in allSnaps {
                            if let dictionary = child.value as? NSDictionary {
                                let ride = Ride(dictionary: dictionary, id: child.key)
                                
                                self?.rides.append(ride)
                            }
                        }
                        
                        self?.ridesTableView.reloadData()
                        self?.startRideRef = lastChilden.key
                    }
                })
        } else {
            ridesReference.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                if snapshot.childrenCount > 0 {
                    guard let lastChilden = snapshot.children.allObjects.last as? DataSnapshot else { return }
                    guard let allSnaps = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    for child in allSnaps {
                        if let dictionary = child.value as? NSDictionary {
                            let ride = Ride(dictionary: dictionary, id: child.key)
                            
                            self?.rides.append(ride)
                        }
                    }
                    
                    self?.ridesTableView.reloadData()
                    self?.startRideRef = lastChilden.key
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: "RideTableViewCell", bundle: nil)
        ridesTableView.register(cellNib, forCellReuseIdentifier: reuseIdentifier)
        
        ridesTableView.delegate = self
        ridesTableView.dataSource = self
        
        ridesReference = Database.database().reference().child(Constants.Rides.ROOT)
        
        //get all not need to un subscribe
        ridesReference?.observeSingleEvent(of: .value, with: {(snapshot) in
            
        })
        loadRides()
    }
    
    func indexOfRide(ride: Ride) -> Int {
        return 1;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            Defaults.removeLoggedUser()
            performSegue(withIdentifier: "goToWellcome", sender: self)
            // TODO: redirect to wellcome VC
        } catch {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let ride = sender as? Ride, let rideDetailsVc = segue.destination as? RideDetailsViewController {
            rideDetailsVc.ride = ride
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let isAnonymous = Auth.auth().currentUser?.isAnonymous else { return }
        
        if !isAnonymous {
            let ride = rides[(indexPath as NSIndexPath).row]
            performSegue(withIdentifier: Constants.Segues.HomeToDetails, sender: ride)
        } else {
            showAlert("Error", "You have to log in first")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //why force unwrap as!
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RideTableViewCell
        
        let ride = rides[indexPath.row]
        
        let rideFrom = ride.from ?? ""
        let rideTo = ride.destination ?? ""
        let freePlaces = ride.freePlaces ?? ""
        let date = Utils.dateFromDate(date: ride.dateOfRide)
        let time = Utils.timeFromDate(date: ride.dateOfRide)
        
        cell.configureCell(fromLocation: rideFrom, destination: rideTo, availablePlaces: freePlaces, time: time, date: date)
        
        return cell
    }
}
