//
//  User.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 25.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

struct User: Codable {
    var id: String
    var email: String
    var name: String
    var phone: String
    var notificationsToken: String?
    var joinedRides: [String:Bool]?
}
