//
//  ChatImageMessageTableViewCell.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 29.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class ChatImageMessageTableViewCell: UITableViewCell {
    
    static let identifier = "imageCell"

    @IBOutlet weak var imageMessage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
