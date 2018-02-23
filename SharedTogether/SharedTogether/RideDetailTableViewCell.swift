//
//  RideDetailTableViewCell.swift
//  SharedTogether
//
//  Created by kristianaatasi on 2/22/18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation
import UIKit

class RideDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!

    func configure(rideJoined: Bool) {

        self.titleLabel.text = rideJoined ? "Leave ride" : "Join ride"
    }
}

