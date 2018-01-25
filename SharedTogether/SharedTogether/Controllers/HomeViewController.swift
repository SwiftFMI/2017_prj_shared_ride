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
    

    @IBOutlet weak var wellcomeLabel: UILabel!
    @IBOutlet weak var ridesTableView: UITableView!
    
    var ridesReference: DatabaseReference?
    var rides: [Ride] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: "RideTableViewCell", bundle: nil)
        ridesTableView.register(cellNib, forCellReuseIdentifier: reuseIdentifier)
        
        if let user = Auth.auth().currentUser {
            if !user.isAnonymous {
                if let userEmail = user.email {
                    wellcomeLabel.text = userEmail
                }
            }
        }
        
        ridesTableView.delegate = self
        ridesTableView.dataSource = self
        
        ridesReference = Database.database().reference().child(Constants.Rides.ROOT)
        
        if let ref = ridesReference {
            // Listen for new comments in the Firebase database
            ref.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                let nsDik = snapshot.value as? NSDictionary
                if let nd = nsDik {
                    let freePlaces = nd[Constants.Rides.FREEPLACES] as! String
                    let destination = nd[Constants.Rides.DESTINATION] as! String
                    let from = nd[Constants.Rides.FROM] as! String
                    let driver = nd[Constants.Rides.DRIVER] as! String
                    let chatId = nd[Constants.Rides.GROUP_CHAT_ID] as! String
                    let ride = Ride(from: from, destination: destination, driver: driver, freePlaces: freePlaces, groupChatId: chatId)
                    self?.rides.append(ride)
                    self?.ridesTableView.reloadData()
                }
                
                
//                if let data = snapshot.value as? [[String: String]] {
//                    do {
//                        let json = try JSONEncoder().encode(data)
//                        do {
//                            let ride = try JSONDecoder().decode(Ride.self, from: json)
//                            self?.rides.append(ride)
//                            self?.ridesTableView.reloadData()
//                        } catch {
//                            print("error \(error)")
//                        }
//
//                    } catch {
//                        print("JSONEncoder: \(error)")
//                    }
//                } else {
//                    print("problem")
//                }
////                do {
////                    let ride = try JSONDecoder().decode(Ride.self, from: snapshot)
////                } catch {
////                    print(error)
////                }
//
//                print(snapshot) // I got the expected number of items
//                for rest in snapshot.children.allObjects {
//                    print(rest)
//                }
//                self?.rides.append(snapshot.getV)
//                let ride = Ride(from: "From: \(snapshot )", destination: "Destination: \()", driver: "Trip driver:\()")
//                let count = self?.rides.count ?? 1
//                self?.ridesTableView.insertRows(at: [IndexPath(row: (count -1), section: self?.kSectionComments)], with: UITableViewRowAnimation.automatic)
            })
            
            // Listen for deleted comments in the Firebase database
//            ref.observe(.childRemoved, with: { [weak self]( snapshot) -> Void in
//                let index = self?.indexOfRide(snapshot)
//                self?.comments.remove(at: index)
//                self?.tableView.deleteRows(at: [IndexPath(row: index, section: self.kSectionComments)], with: UITableViewRowAnimation.automatic)
//            })
        }
        // Do any additional setup after loading the view.
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
            performSegue(withIdentifier: "goToWellcome", sender: self)
            // TODO: redirect to wellcome VC
        } catch {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let ride = sender as? Ride {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.groupId = ride.groupChatId
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ride = rides[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: Constants.Segues.HomeToChat, sender: ride)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? RideTableViewCell {
            let ride = rides[indexPath.row]
            
            var from = "";
            if let fromUnWraped = ride.from {
                from = "From: \(fromUnWraped)"
            }
            
            var dest = "";
            if let destinationUnWraped = ride.destination {
                dest = "Destination: \(destinationUnWraped)"
            }
            
            var driver = "";
            if let driverUnWraped = ride.driver {
                driver = "Driver: \(driverUnWraped)"
            }
                
                
            cell.configureCell(fromLocation: from, destination: dest, driverName: driver)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.delegate = self
            return cell;
        } else {
            return UITableViewCell()
        }
    }
}

extension HomeViewController: RideCellItemsTap {
    func joinTab(cell: RideTableViewCell) {
        performSegue(withIdentifier: "HomeToChat", sender: self)
    }
    
    func onLeaveTab(cell: RideTableViewCell) {
        performSegue(withIdentifier: "HomeToChat", sender: self)
    }
    
    func onOpenChatTab(cell: RideTableViewCell) {
        performSegue(withIdentifier: "HomeToChat", sender: self)
    }
    
    
}
