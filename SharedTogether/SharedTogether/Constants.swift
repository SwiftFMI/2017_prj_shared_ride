//
//  Constants.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 9.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Defaults {
        static let USER = "logedUser"
    }
    
    struct UserDefaults {
        static let USER = "loged_user"
    }
    struct Segues {
        static let DetailsToChat = "DetailsToChat"
        static let HomeToDetails = "HomeToDetails"
    }
    
    struct Users {
        static let ROOT = "users"
        
        static let ID = "id"
        static let EMAIL = "email"
        static let NAME = "name"
        static let PHONE = "phone"
        static let JOINED_RIDES = "joinedRides"
        static let NOTIFICATIONS_TOKEN = "notificationsToken"
    }
    
    struct Rides {
        static let ROOT = "rides"
        
        //childs
        static let FROM = "from"
        static let DESTINATION = "destination"
        static let FREEPLACES = "freePlaces"
        static let GROUP_CHAT_ID = "groupChatId"
        static let DRIVER = "driver"
        static let OWNER_ID = "ownerId"
        static let START_RIDE_DATE = "startRideDate"
        static let CREATION_DATE = "creationDate"
    }
    
    struct RidesGroupChat {
        static let ROOT = "ridesGroups"
        
        //childs
        static let CHAT_MEMBERS = "chatMembers"
        static let MESSAGESS = "messagess"
        static let MESSAGESS_USER_ID = "fromId"
        static let MESSAGESS_USER_MESSAGE = "message"
        static let MESSAGES_IMAGE_URL = "imageUrl"
        static let MESSAGES_DATE = "messagesDate"
    }
    
    struct ChatNotifications {
        static let ROOT = "chatNotifications"
        // dictionary userUuid - bool
    }
    
    struct UserCreatedRides {
        static let ROOT = "userCreatedRides"
        // dictionary ride Uuid - bool
    }
    
    struct RidesLocation {
        static let ROOT = "ridesLocation"
        
        static let TO = "to"
        static let LONGITUDE = "longitude"
        static let LATITUDE = "latitude"
    }
    
    struct Storage {
        static let CHAT_IMAGES = "chatImages"
    }
}
