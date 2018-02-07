//
//  Message.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 26.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

struct Message {
    var fromId: String
    var message: String
    var imageURI: String
    
    init(dictionary: NSDictionary) {
        fromId = dictionary[Constants.RidesGroupChat.MESSAGESS_USER_ID] as? String ?? ""
        message = dictionary[Constants.RidesGroupChat.MESSAGESS_USER_MESSAGE] as? String ?? ""
        imageURI = dictionary[Constants.RidesGroupChat.MESSAGES_IMAGE_URL] as? String ?? ""
    }
}
