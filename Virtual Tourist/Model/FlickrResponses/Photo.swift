//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-09.
//  Copyright © 2021 Udacity. All rights reserved.
//

import Foundation

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    let url: String
    let heightM: Int
    let widthM: Int
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case url = "url_m"
        case heightM = "height_m"
        case widthM = "width_m"
    }
}
