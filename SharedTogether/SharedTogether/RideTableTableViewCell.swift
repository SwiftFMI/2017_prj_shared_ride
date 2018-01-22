//
//  RideTableTableViewCell.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 16.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class RideTableTableViewCell: UITableViewCell {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var openChatButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(fromLocation: String, destination: String, driverName: String) {
        if fromLabel != nil && destinationLabel != nil && driverNameLabel != nill {
            fromLabel.text=fromLocation
            destinationLabel.text=destination
            driverNameLabel.text=driverName
        }
    }
    
    //how to handle click on deiferent data items
    @IBAction func onJoinTab(_ sender: UIButton) {
    }
    
    @IBAction func onLeaveTab(_ sender: UIButton) {
    }
    
    @IBAction func onOpenChatTab(_ sender: UIButton) {
    }
}
