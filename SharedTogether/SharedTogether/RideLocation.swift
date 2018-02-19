//
//  RideLocation.swift
//  SharedTogether
//
//  Created by kristianaatasi on 2/19/18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

struct RideLocation: Codable {
    var rideId: String?
    
    var destination: String?
    var latitude: Double?
    var longitude: Double?
}
