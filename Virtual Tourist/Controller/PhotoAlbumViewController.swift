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
    var fetchedResultsController: NSFetchedResultsController<Picture>!
    var blockOperations = [BlockOperation]()
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
//    fileprivate func setUpFetchRequest() {
//        let fetchRequest: NSFetchRequest<Picture> = Picture.fetchRequest()
//        let predicate = NSPredicate(format: "pin == %@", pin)
//        fetchRequest.predicate = predicate
//
//        if let result = try? dataController.viewContext.fetch(fetchRequest) {
////            for urlString in result {
////                photoArray.append(urlString.url ?? "")
////            }
//
//            for picture in result {
//                if let fetchedData = picture.image {
//                    photoAlbum.append(UIImage(data: fetchedData)!)
//                }
//            }
//
//        }
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        
        setupCollectionViewLayout()
    }
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Picture> = Picture.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Latitude: \(String(latitude)), Longitude: \(String(longitude))")
        print("Latitude: \(pin.latitude)")
        print("Longitude: \(pin.longitude)")
//        updateButton(false)
        resultsLabel.isHidden = true
        loadMapViewLocation()
        
        setUpFetchedResultsController()
        // setUpFetchRequest()
        
//        if photoArray.isEmpty {
//            FlickrClient.searchPhotos(latitude: latitude, longitude: longitude, page: 1, completion: handleSearchPhotosResponse(photos:error:))
//            collectionView.reloadData()
//        }
        
        // Try this
        if fetchedResultsController.fetchedObjects!.isEmpty {
            FlickrClient.searchPhotos(latitude: latitude, longitude: longitude, page: 1, completion: handleSearchPhotosResponse(photos:error:))
            collectionView.reloadData()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
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
        updateButton(false)
        
        if error != nil || photos.isEmpty {
            print(error.debugDescription)
            resultsLabel.isHidden = false
            //newCollectionButton.isEnabled = false
            // activityIndicator.stopAnimating()
            updateButton(true)
        }
        else {
            for photo in photos {
//                let downloadedPhoto = Picture(context: dataController.viewContext)
//                downloadedPhoto.url = photo.urlM
                print(photo.urlM)
                photoArray.append(photo.urlM)
                updateButton(true)
                
                
                // Try This
                let downloadedPhoto = Picture(context: dataController.viewContext)
                downloadedPhoto.url = photo.urlM
                let photoURL = URL(string: downloadedPhoto.url!)!
                
                FlickrClient.getImage2(url: photoURL) { (data, error) in
                    guard let data = data else {
                        return
                    }
                    downloadedPhoto.image = data
                    downloadedPhoto.pin = self.pin
                    try? self.dataController.viewContext.save()
                    self.setUpFetchedResultsController()
//                    DispatchQueue.main.async {
//                        self.collectionView.reloadData()
//                    }
                }
                
                
                
            }
        }
        // updateButton(true)
        print(photoArray.count)
        updateButton(true)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    
    @IBAction func getNewCollection(_ sender: UIBarButtonItem) {
        
        if let photoObjects = fetchedResultsController?.fetchedObjects {
            for photo in photoObjects {
                dataController.viewContext.delete(photo)
            }
        }
        try? dataController.viewContext.save()
        setUpFetchedResultsController()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }

        resultsLabel.isHidden = true
        updateButton(false)
        // fetchedResultsController.fetchedObjects?.removeAll()
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
        // return 1
        // Try this
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return photoArray.count
        // Try this
        // print(fetchedResultsController.sections?[section].numberOfObjects)
        // return photoArray.count != 0 ? photoArray.count : fetchedResultsController.sections?[section].numberOfObjects ?? 0
//        return fetchedResultsController.sections?[section].numberOfObjects ?? photoArray.count
        
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomPhotoCell", for: indexPath) as! CustomPhotoCell
        
        cell.collectionImageView.image = UIImage(named: "VirtualTourist_1024")
        
//        if !photoAlbum.isEmpty {
//
//            let image = photoAlbum[indexPath.row]
//            cell.collectionImageView.image = image
//
//        }
        // Try This
        if !fetchedResultsController.fetchedObjects!.isEmpty {
            if let imageData = fetchedResultsController.object(at: indexPath).image {
                cell.collectionImageView.image = UIImage(data: imageData)
            }
        }
        else {
//            if photoArray.count >= 1 {
//                let photoString = photoArray[indexPath.row]
//                let photoURL = URL(string: photoString)!
//                print("PhotoURL: \(photoURL)")
//
//
//                let downloadedPhoto = Picture(context: dataController.viewContext)
//                downloadedPhoto.url = photoString
//
////                FlickrClient.getImage(url: photoURL) { (image, error) in
////                    if let downloadedImage = image {
////                        DispatchQueue.main.async {
////                            cell.collectionImageView.image = downloadedImage
////                            cell.setNeedsLayout()
////                        }
////                    }
////                }
//
//                FlickrClient.getImage2(url: photoURL) { (data, error) in
//                    guard let data = data else {
//                        return
//                    }
//                    downloadedPhoto.image = data
//                    if let downloadedImage = UIImage(data: data) {
//                        DispatchQueue.main.async {
//                            cell.collectionImageView.image = downloadedImage
//                            cell.setNeedsLayout()
//                        }
//                    }
//                    downloadedPhoto.pin = self.pin
//                    // try? self.dataController.viewContext.save()
//                    self.setUpFetchedResultsController()
//                    DispatchQueue.main.async {
//                        collectionView.reloadData()
//                    }
//                }
//            } else {
                cell.collectionImageView.image = UIImage(named: "VirtualTourist_1024")
            }
        //}
        
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
//        if !photoArray.isEmpty {
//            photoArray.remove(at: indexPath.item)
//            collectionView.deleteItems(at: [indexPath])
//            if photoArray.isEmpty {
//                resultsLabel.isHidden = false
//            }
//        }
//        collectionView.reloadData()
        
        let itemToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(itemToDelete)
        try? dataController.viewContext.save()
        
        if let numberOfObjects = fetchedResultsController.fetchedObjects {
            if numberOfObjects.isEmpty {
                resultsLabel.isHidden = false
            }
        }
        collectionView.reloadData()
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



extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for operation in blockOperations {
                operation.start()
            }
        }) { (completed) in
            self.blockOperations.removeAll()
            self.collectionView.reloadData()
//            let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
//            let indexPath = IndexPath(item: lastItem, section: 0)
//            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.insertItems(at: [newIndexPath!])
            }))
            
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.deleteItems(at: [indexPath!])
            }))
            
        case .move:
            blockOperations.append(BlockOperation(block: { [weak self] in
               self?.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            }))
        case .update:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.reloadItems(at: [indexPath!])
            }))
        @unknown default:
            break
        }
    }
}
