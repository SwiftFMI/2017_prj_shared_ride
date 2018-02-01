//
//  RideTableTableViewCell.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 16.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class RideTableViewCell: UITableViewCell, IdentifiableCell {
    
    static var cellIdentifier: String {
        return String(describing: RideTableViewCell.self)
    }
    
    @IBOutlet weak var cellContentView: UIView!

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var availableSeatsLabel: UILabel!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var openChatButton: UIButton!
    
    weak var delegate: RideCellItemsTap?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellContentView.layer.cornerRadius = 3.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(fromLocation: String, destination: String) {
        if fromLabel != nil && destinationLabel != nil {
            fromLabel.text=fromLocation
            destinationLabel.text=destination
        }
    }
    
    //how to handle click on deiferent data items
    @IBAction func onJoinTab(_ sender: UIButton) {
        if let callback = delegate {
            callback.joinTab(cell: self)
        }
    }
    
    @IBAction func onLeaveTab(_ sender: UIButton) {
        if let callback = delegate {
            callback.onLeaveTab(cell: self)
        }
    }
    
    @IBAction func onOpenChatTab(_ sender: UIButton) {
        if let callback = delegate {
            callback.onOpenChatTab(cell: self)
        }
    }
}

protocol RideCellItemsTap: NSObjectProtocol {
    func joinTab(cell: RideTableViewCell)
    
    func onLeaveTab(cell: RideTableViewCell)
    
    func onOpenChatTab(cell: RideTableViewCell)
}
