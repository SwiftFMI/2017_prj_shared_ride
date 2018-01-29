//
//  ChatMessageTableViewCell.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 26.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var participantMessageLabel: UILabel!
    @IBOutlet weak var chatImageImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func prepare(participantName: String, participantMessage: String) {
        participantNameLabel.text = participantName
        participantMessageLabel.text = participantMessage
    }
    
}
