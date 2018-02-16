//
//  ChatDetailTableViewCell.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 15.02.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class ChatDetailTableViewCell: UITableViewCell, IdentifiableCell {
    
    static var cellIdentifier: String {
        return String(describing: ChatDetailTableViewCell.self)
    }
    
    @IBOutlet weak var rideParticipantName: UILabel!
    @IBOutlet weak var rideParticipantPhone: UILabel!
    weak var delegate: ChatDetailCallTap?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(name: String, phone: String) {
        rideParticipantName.text = name
        rideParticipantPhone.text = phone
    }
    
    @IBAction func onCallTap(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.callTapped(cell: self)
        }
    }
}

protocol ChatDetailCallTap: NSObjectProtocol {
    func callTapped(cell: ChatDetailTableViewCell)
}
