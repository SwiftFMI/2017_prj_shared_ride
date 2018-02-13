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

class HomeViewController: UIViewController {
//    present pop Over VC
    

    @IBOutlet weak var ridesTableView: UITableView!
    
    var ridesReference: DatabaseReference?
    var rides: [Ride] = []
    var user = Defaults.getLoggedUser()
    var observeAdded: DatabaseHandle?
    var observeChanged: DatabaseHandle?
    var observeRemoved: DatabaseHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        user = Defaults.getLoggedUser()
        
        if let ref = ridesReference {
            //TODO: add pagination  and synchronize .value and .childAdded
            observeAdded = ref.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                if let dictionary = snapshot.value as? NSDictionary {
                    let ride = Ride(dictionary: dictionary, id: snapshot.key)

                    self?.rides.append(ride)
                    self?.ridesTableView.reloadData()
                }
            })
            
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
        let ride = rides[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: Constants.Segues.HomeToDetails, sender: ride)
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
