//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-10.
//  Copyright © 2021 Udacity. All rights reserved.
//

import Foundation

// MARK: - PhotosResponse
struct PhotosResponse: Codable {
    let photos: Photos
    let stat: String
}


// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}


// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
    let urlM: String
    let heightM, widthM: Int
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
        case urlM = "url_m"
        case heightM = "height_m"
        case widthM = "width_m"
    }
}
