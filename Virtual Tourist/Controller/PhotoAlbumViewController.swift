//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-03.
//  Copyright © 2021 Udacity. All rights reserved.
//

import UIKit
import MapKit

// MARK: - CollectionViewCell Class
class CustomPhotoCell: UICollectionViewCell {
    @IBOutlet weak var collectionImageView: UIImageView!
}


// MARK: - PhotoAlbumViewController Class
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
        
        setupCollectionViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Latitude: \(String(latitude)), Longitude: \(String(longitude))")
        loadMapViewLocation()
        
        FlickrClient.searchPhotos(latitude: latitude, longitude: longitude, completion: handleSearchPhotosResponse(photos:error:))
        collectionView.reloadData()
    }
    
    
    // MARK: - Methods
    
    func setupCollectionViewLayout() {
        let spacing: CGFloat = 5
        let width = UIScreen.main.bounds.width
        flowLayout.estimatedItemSize = .zero
        flowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: 50, right: spacing)
        let numberOfItems: CGFloat = 3
        let itemSize = (width - (spacing * (numberOfItems + 1))) / numberOfItems
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
        }
        else {
            for photo in photos {
                print(photo.urlM)
                photoArray.append(photo.urlM)
            }
        }
        print(photoArray.count)
        collectionView.reloadData()
    }

}


// MARK: - PhotoAlbumViewController Extension
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - UICollectionView Delegate & DataSource Method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomPhotoCell", for: indexPath) as! CustomPhotoCell
        
        let photoString = photoArray[indexPath.row]
        let photoURL = URL(string: photoString)!
        print("PhotoURL: \(photoURL)")

        FlickrClient.getImage(url: photoURL) { (image, error) in
            if let downloadedImage = image {
                DispatchQueue.main.async {
                    cell.collectionImageView.image = downloadedImage
                    cell.setNeedsLayout()
                }
            }
        }
        return cell
    }
    
}
