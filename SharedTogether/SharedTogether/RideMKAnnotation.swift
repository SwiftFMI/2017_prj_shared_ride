//
//  RideMKAnnotation.swift
//  SharedTogether
//
//  Created by kristianaatasi on 2/20/18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class RideMKAnnotation: NSObject, MKAnnotation {
    
    static let reuseIdentifier = String(describing: self)
    
    var rideId: String?
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(latitute: CLLocationDegrees, longitude: CLLocationDegrees, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = CLLocationCoordinate2DMake(latitute, longitude)
        self.title = title
        self.subtitle = subtitle
    }
}
