//
//  RideProfileTableViewCell.swift
//  SharedTogether
//
//  Created by kristianaatasi on 2/22/18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation
import UIKit

class RideProfileTableViewCell: UITableViewCell, IdentifiableCell {
    
    @IBOutlet weak var resortLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configure(resort: String, date: String) {
        resortLabel.text = resort
        dateLabel.text = date
    }
}
