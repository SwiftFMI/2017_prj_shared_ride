//
//  Ride.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 19.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

struct Ride: Codable {
    var id: String?
    var from: String?
    var destination: String?
    var driver: String?
    var freePlaces: String?
    var groupChatId: String?
    var ownerId: String?
}
