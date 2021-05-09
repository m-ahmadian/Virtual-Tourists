//
//  ErrorResponse.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-09.
//  Copyright © 2021 Udacity. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
    
//    enum CodingKeys: String, CodingKey {
//        case stat
//        case code
//        case message
//    }
}


extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
