//
//  Pin+Extensions.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-06-09.
//  Copyright © 2021 Udacity. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latitudeDegrees = CLLocationDegrees(latitude)
        let longitudeDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latitudeDegrees, longitude: longitudeDegrees)
    }
}
