//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-03.
//  Copyright © 2021 Udacity. All rights reserved.
//

import UIKit
import MapKit

class CustomPhotoCell: UICollectionViewCell {
    @IBOutlet weak var collectionImageView: UIImageView!
}

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    // MARK: - Properties
    var latitude: Double!
    var longitude: Double!
    var zoomLevel: MKCoordinateSpan!
    var photoAlbum: [UIImage] = []
    var photoArray: [String] = []

    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        let space: CGFloat = 3.0
//        let dimensionWidth = (collectionView.frame.width - (2 * space)) / 3
//        let dimensionHeight = (collectionView.frame.height - (4 * space)) / 5
//
//        flowLayout.minimumLineSpacing = space
//        flowLayout.minimumInteritemSpacing = space
//        flowLayout.itemSize = CGSize(width: dimensionWidth, height: dimensionHeight)
//
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CustomPhotoCell")
        
        setupCollectionViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("Latitude: \(String(describing: latitude)), Longitude: \(String(describing: longitude))")
        print("Latitude: \(String(latitude)), Longitude: \(String(longitude))")
        loadMapViewLocation()
        
        FlickrClient.searchPhotos(latitude: latitude, longitude: longitude, completion: handleSearchPhotosResponse(photos:error:))
        
        print("Finished 1st get request")
        collectionView.reloadData()
    }
    
    
    // MARK: - Methods
    
    func setupCollectionViewLayout() {
        let spacing: CGFloat = 5
        let width = UIScreen.main.bounds.width
        flowLayout.estimatedItemSize = .zero
        flowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: 50, right: spacing)
        let numberOfItems: CGFloat = 3
        let itemSize = (width - (spacing * (numberOfItems+1))) / numberOfItems
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        collectionView.collectionViewLayout = flowLayout
    }
    
    
    func loadMapViewLocation() {
        
        let mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let currentRegion = MKCoordinateRegion(center: mapCenter, span: zoomLevel)
        mapView.setRegion(currentRegion, animated: true)
    }

    func handleSearchPhotosResponse(photos: [Photo], error: Error?) {
        if error != nil {
            print(error.debugDescription)
//            return
        }
        else {
            for photo in photos {
                
//                let flickerImageURLAddress = URL(string:"https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_m.jpg")!
//                FlickrClient.getImage(url: flickerImageURLAddress, completion: handleGetImageResponse(image:error:))
                
                // Try this
                print(photo.urlM)
                photoArray.append(photo.urlM)
                print("Is the first one happening")
            }
        }
        
        print("Is the second one happening")
    }
    
    func handleGetImageResponse(image: UIImage?, error: Error?) {
        if let downloadedImage = image {
            photoAlbum.append(downloadedImage)
        }
    }

}


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - UICollectionView Delegate & DataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return photoAlbum.count
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomPhotoCell", for: indexPath) as! CustomPhotoCell
        
        // let photo = photoAlbum[indexPath.row]
        
        // Try this
//        let photoURL = URL(string: photoArray[indexPath.row])!
//        print("PhotoURL: \(photoURL)")
//
//        FlickrClient.getImage(url: photoURL) { (image, error) in
//            if let downloadedImage = image {
//                DispatchQueue.main.async {
//                    cell.collectionImageView.image = downloadedImage
//                }
//            }
//        }
//
//        collectionView.reloadData()
        
        cell.collectionImageView.image = UIImage(named: "VirtualTourist_1024")
        
//        DispatchQueue.main.async {
//            cell.collectionImageView.image = photo
//        }
        
        return cell
    }
    
    
}
