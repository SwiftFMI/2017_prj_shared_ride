//
//  Constants.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 9.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

struct Constants {
    static let USERS = "users"
    
    struct UserDefaults {
        static let USER = "loged_user"
    }
    struct Segues {
        static let HomeToChat = "HomeToChat"
    }
    
    struct Users {
        static let ROOT = "users"
        
        static let ID = "id"
        static let EMAIL = "email"
        static let NAME = "name"
        static let PHONE = "phone"
    }
    
    struct Rides {
        static let ROOT = "rides"
        
        //childs
        static let FROM = "from"
        static let DESTINATION = "destination"
        static let FREEPLACES = "freePlaces"
        static let GROUP_CHAT_ID = "groupChatId"
        static let DRIVER = "driver"
    }
    
    struct RidesGroupChat {
        static let ROOT = "ridesGroups"
        
        //childs
        static let CHAT_MEMBERS = "chatMembers"
        static let MESSAGESS = "messagess"
        static let MESSAGESS_USER_ID = "fromId"
        static let MESSAGESS_USER_MESSAGE = "message"
    }
}
