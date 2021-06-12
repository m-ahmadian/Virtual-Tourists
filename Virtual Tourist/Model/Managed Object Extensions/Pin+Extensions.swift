//
//  Pin+Extensions.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-06-09.
//  Copyright © 2021 Udacity. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
//        guard let latitude = latitude, let longitude = longitude else {
//            return kCLLocationCoordinate2DInvalid
//        }
//
//        let latitudeDegrees = CLLocationDegrees(latitude.doubleValue)
//        let longitudeDegrees = CLLocationDegrees(longitude.doubleValue)
//        return CLLocationCoordinate2D(latitude: latitudeDegrees, longitude: longitudeDegrees)
        
        let latitudeDegrees = CLLocationDegrees(latitude)
        let longitudeDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latitudeDegrees, longitude: longitudeDegrees)
    }
    
    
}

//public var coordinate: CLLocationCoordinate2D {
//    // latitude and longitude are optional NSNumbers
//    guard let latitude = latitude, let longitude = longitude else {
//        return kCLLocationCoordinate2DInvalid
//    }
//
//    let latDegrees = CLLocationDegrees(latitude.doubleValue)
//    let longDegrees = CLLocationDegrees(longitude.doubleValue)
//    return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
//}
