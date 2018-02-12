//
//  Ride.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 19.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

struct Ride: Codable {
    var rideId: String?
    var from: String?
    var destination: String?
    var driver: String?
    var freePlaces: String?
    var groupChatId: String?
    var ownerId: String?
    var dateOfRide: Date?
    
    init(dictionary: NSDictionary, id: String?) {
        rideId = id ?? ""
        freePlaces = dictionary[Constants.Rides.FREEPLACES] as? String ?? ""
        destination = dictionary[Constants.Rides.DESTINATION] as? String ?? ""
        from = dictionary[Constants.Rides.FROM] as? String ?? ""
        driver = dictionary[Constants.Rides.DRIVER] as? String ?? ""
        groupChatId = dictionary[Constants.Rides.GROUP_CHAT_ID] as? String ?? ""
        ownerId = dictionary[Constants.Rides.OWNER_ID] as? String ?? ""
        let dateUnixTimestamp = dictionary[Constants.Rides.START_RIDE_DATE] as? String ?? ""
        dateOfRide = Utils.dateFromTimestampString(stringUnixTimeStamp: dateUnixTimestamp)
    }
}
