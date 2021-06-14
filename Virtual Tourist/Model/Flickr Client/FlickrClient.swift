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
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/"
        static let flickrPhotosSearch = "?method=flickr.photos.search"
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
        
        case searchPhotos(Double, Double, Int)
        
        var stringValue: String {
            switch self {
            case .searchPhotos(let latitude, let longitude, let page):
                return Endpoints.base + Endpoints.flickrPhotosSearch + Endpoints.apiKeyParam + "&lat=\(latitude)" + "&lon=\(longitude)" + "&extras=url_m&per_page=20&page=\(page)&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    class func searchPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping ([Photo], Error?) -> Void) {
        print(Endpoints.searchPhotos(latitude, longitude, page).url)
        
        var request = URLRequest(url: Endpoints.searchPhotos(latitude, longitude, page).url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        taskForGETRequest(url: request, response: PhotosResponse.self) { (response, error) in
            if let response = response {
                print(response)
                print(response.stat)
                print(response.photos.photo)
                completion(response.photos.photo, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    
    // Delete this class func after test completion
    /*
    class func getImage(url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
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
    */
    
    
    class func getImage2(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
    
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URLRequest, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
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
                print(responseObject)
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
