//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-03.
//  Copyright © 2021 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

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
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    var dataController: DataController!
    var pin: Pin!
    var annotations = [MKPointAnnotation]()
    var annotation: MKPointAnnotation!
    var latitude: Double!
    var longitude: Double!
    var zoomLevel: MKCoordinateSpan!
    var currentRegion: MKCoordinateRegion!
    var photoAlbum: [UIImage] = []
    var photoArray: [String] = []
    var count = 1

    
    // MARK: - View Life Cycle
    fileprivate func setUpFetchRequest() {
        let fetchRequest: NSFetchRequest<Picture> = Picture.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
//            for urlString in result {
//                photoArray.append(urlString.url ?? "")
//            }
            
            for picture in result {
                if let fetchedData = picture.image {
                    photoAlbum.append(UIImage(data: fetchedData)!)
                }
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        
        setupCollectionViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Latitude: \(String(latitude)), Longitude: \(String(longitude))")
        updateButton(false)
        resultsLabel.isHidden = true
        loadMapViewLocation()
        
        setUpFetchRequest()
        
        if photoArray.isEmpty {
            FlickrClient.searchPhotos(latitude: latitude, longitude: longitude, page: 1, completion: handleSearchPhotosResponse(photos:error:))
            collectionView.reloadData()
        }
        
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
        mapView.reloadInputViews()
    }
    
    func loadMapViewLocation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotations.append(annotation)
        mapView.addAnnotation(annotation)
        
        mapView.setRegion(currentRegion, animated: true)
    }

    func handleSearchPhotosResponse(photos: [Photo], error: Error?) {
        if error != nil || photos.isEmpty {
            print(error.debugDescription)
            resultsLabel.isHidden = false
            newCollectionButton.isEnabled = false
            activityIndicator.stopAnimating()
        }
        else {
            for photo in photos {
                print(photo.urlM)
                photoArray.append(photo.urlM)
                updateButton(true)
            }
        }
        // updateButton(true)
        print(photoArray.count)
        collectionView.reloadData()
    }
    
    @IBAction func getNewCollection(_ sender: UIBarButtonItem) {
        resultsLabel.isHidden = true
        updateButton(false)
        count += 1
        photoArray.removeAll()
        if count >= 1 {
            FlickrClient.searchPhotos(latitude: latitude, longitude: longitude, page: count, completion: handleSearchPhotosResponse(photos:error:))
        } else {
            count = 1
        }
    }
    
    // Update New Collection Button
    func updateButton(_ finishedDownloading: Bool) {
        newCollectionButton.isEnabled = finishedDownloading
        finishedDownloading ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
}


// MARK: - PhotoAlbumViewController Extension
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - UICollectionView Delegate & DataSource Method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return !photoArray.isEmpty ? photoArray.count : 1
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomPhotoCell", for: indexPath) as! CustomPhotoCell
        
        cell.collectionImageView.image = UIImage(named: "VirtualTourist_1024")
        
        if !photoAlbum.isEmpty {
            
            let image = photoAlbum[indexPath.row]
            cell.collectionImageView.image = image
            
        } else {
            if photoArray.count >= 1 {
                let photoString = photoArray[indexPath.row]
                let photoURL = URL(string: photoString)!
                print("PhotoURL: \(photoURL)")
                
                
                let downloadedPhoto = Picture(context: dataController.viewContext)
                downloadedPhoto.url = photoString
                
//                FlickrClient.getImage(url: photoURL) { (image, error) in
//                    if let downloadedImage = image {
//                        DispatchQueue.main.async {
//                            cell.collectionImageView.image = downloadedImage
//                            cell.setNeedsLayout()
//                        }
//                    }
//                }
                
                FlickrClient.getImage2(url: photoURL) { (data, error) in
                    guard let data = data else {
                        return
                    }
                    downloadedPhoto.image = data
                    if let downloadedImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.collectionImageView.image = downloadedImage
                            cell.setNeedsLayout()
                        }
                    }
                    downloadedPhoto.pin = self.pin
                    try? self.dataController.viewContext.save()
                }
            } else {
                cell.collectionImageView.image = UIImage(named: "VirtualTourist_1024")
            }
        }
        
//        if photoArray.count >= 1 {
//            let photoString = photoArray[indexPath.row]
//            let photoURL = URL(string: photoString)!
//            print("PhotoURL: \(photoURL)")
//
//            let downloadedPhoto = Picture(context: dataController.viewContext)
//            downloadedPhoto.url = photoString
//
//            FlickrClient.getImage(url: photoURL) { (image, error) in
//                if let downloadedImage = image {
//                    DispatchQueue.main.async {
//                        cell.collectionImageView.image = downloadedImage
//                        cell.setNeedsLayout()
//                    }
//                }
//            }
//        } else {
//            cell.collectionImageView.image = UIImage(named: "VirtualTourist_1024")
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !photoArray.isEmpty {
            photoArray.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
            if photoArray.isEmpty {
                resultsLabel.isHidden = false
            }
        }
    }
    
}

extension PhotoAlbumViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        
        pinView?.displayPriority = .required
        return pinView
    }
}
