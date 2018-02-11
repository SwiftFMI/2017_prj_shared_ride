//
//  LeaveRideEmitter.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 10.02.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

class LeaveRideEmitter {
    
    static let shared = LeaveRideEmitter()
    
    var leaveRideEvents: [LeaveRide]
    
    private init() {
        leaveRideEvents = [LeaveRide]()
    }
    
    func addLeaveRideEvent(leaveRide: LeaveRide) {
        leaveRideEvents.append(leaveRide)
    }
    
    func startLoop() {
        
    }
    
    func stopLoop() {
        
    }
}
