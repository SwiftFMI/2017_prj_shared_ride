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
    
    override var coordinate: CLLocationCoordinate2D
    override var title: String?
    override var subtitle: String?
    
    init(latitute: CLLocationDegrees, longitude: CLLocationDegrees, title: String? = nil, subtitle: String? = nil) {
        coordinate = CLLocationCoordinate2DMake(latitute, longitude)
        title = title
        subtitle = subtitle
    }
}
