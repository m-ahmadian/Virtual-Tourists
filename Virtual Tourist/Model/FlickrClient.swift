//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-07.
//  Copyright © 2021 Udacity. All rights reserved.
//

import Foundation
import UIKit


class FlickrClient {
    
    private static let apiKey = "5ef27c06449c66e2fd8578e931c31ade"
    private static let secret = "6b0bd14f524849ea"
    
    private struct Auth {
        static var accountId = 0
    }
    
//     https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=c98a058f0a3d0a7121a7eeeee1947421&lat=43.6532&lon=79.3832&per_page=20&page=1&format=json
    
    enum Endpoints {
        
        static let base = "https://www.flickr.com/services/rest/"
        static let flickrPhotosSearch = "?method=flickr.photos.search"
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
        
        case searchPhotos(Double, Double)
        
        var stringValue: String {
            switch self {
            case .searchPhotos(let latitude, let longitude):
                return Endpoints.base + Endpoints.flickrPhotosSearch + Endpoints.apiKeyParam + "&lat=\(latitude)" + "&lon=\(longitude)" + "&per_page=20&page=1&format=json"
            default:
                print("default")
                //
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    
    class func searchPhotos(latitude: Double, longitude: Double, completion: @escaping ([Photo], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.searchPhotos(latitude, longitude).url, response: Photos.self) { (response, error) in
            if let response = response {
                completion(response.photo, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getImage(flickrImageUrlAddress: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let url = URL(string: flickrImageUrlAddress)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let downloadedImage = UIImage(data: data)
            DispatchQueue.main.async {
                completion(downloadedImage, nil)
            }
        }
        task.resume()
    }
    
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) // as? Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
}