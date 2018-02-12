//
//  MyProfileViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 12.02.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {

    @IBOutlet weak var myProfileView: UIView!
    @IBOutlet weak var myRidesView: UIView!
    @IBOutlet weak var joinedRidesView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myRidesView.isHidden = false
        myRidesView.isHidden = true
        joinedRidesView.isHidden = true
        
        user = Defaults.getLoggedUser()
        
        if let user = user {
            userNameLabel.text = user.email
            userAvatarImageView.layer.cornerRadius = 45
            userAvatarImageView.backgroundColor = .gray
        }
    }
    
    @IBAction func segmentedControllClick(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            myProfileView.isHidden = false
            myRidesView.isHidden = true
            joinedRidesView.isHidden = true
        case 1:
            myProfileView.isHidden = true
            myRidesView.isHidden = false
            joinedRidesView.isHidden = true
        case 2:
            myProfileView.isHidden = true
            myRidesView.isHidden = true
            joinedRidesView.isHidden = false
        default:
            print("Default")
        }
    }
}
