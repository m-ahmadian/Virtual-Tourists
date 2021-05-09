//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-09.
//  Copyright © 2021 Udacity. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photo: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}
