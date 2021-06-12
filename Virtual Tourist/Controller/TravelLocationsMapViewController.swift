//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-03.
//  Copyright © 2021 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class TravelLocationsMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Properties
    var dataController: DataController!
    var selectedPin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var blockOperations = [BlockOperation]()
    var annotations = [MKPointAnnotation]()
    var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var selectedPinView: MKAnnotationView = MKAnnotationView()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var latitudeDelta: Double = 0.0
    var longitudeDelta: Double = 0.0
    var zoomLevel: MKCoordinateSpan = MKCoordinateSpan()
    var currentRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    
    // MARK: - View Life Cycle
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setUpFetchedResultsController()
        setUpMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapViewLocation()
        fetchedResultsController = nil
    }
    
    
    // MARK: Helper Methods
    
    func setUpMapView() {
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            print("App has launched before")
            loadMapViewLocation()
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            saveMapViewLocation()
        }
    }

    func saveMapViewLocation() {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "latitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "longitude")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
        
        currentRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "latitude"), longitude: UserDefaults.standard.double(forKey: "longitude")), span: MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "latitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "longitudeDelta")))
        
        UserDefaults.standard.synchronize()
    }
    
    func loadMapViewLocation() {
        
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        
        latitude = UserDefaults.standard.double(forKey: "latitude")
        longitude = UserDefaults.standard.double(forKey: "longitude")
        latitudeDelta = UserDefaults.standard.double(forKey: "latitudeDelta")
        longitudeDelta = UserDefaults.standard.double(forKey: "longitudeDelta")
        centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        zoomLevel = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        currentRegion = MKCoordinateRegion(center: centerCoordinate, span: zoomLevel)
        mapView.setRegion(currentRegion, animated: true)
        
        // Create a Pin object
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                annotations.append(annotation)
            }
        }
        self.mapView.addAnnotations(annotations)
    }

    
    // MARK: - Actions
    
    @IBAction func mapTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            addPin(sender)
        }
    }
    
    fileprivate func addPin(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = locationCoordinate.latitude
        pin.longitude = locationCoordinate.longitude
        try? dataController.viewContext.save()
    }
    
}


// MARK: - Extension for MKMapViewDelegate Methods

extension TravelLocationsMapViewController {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        saveMapViewLocation()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapViewLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "location"
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedPinView = view
        
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                if pin.latitude == self.selectedPinView.annotation?.coordinate.latitude && pin.longitude == self.selectedPinView.annotation?.coordinate.longitude {
                    selectedPin = pin
                }
            }
        }
        
        let alert = UIAlertController(title: "Marked Location", message: "Latitude: \(selectedPinView.annotation?.coordinate.latitude ?? 0.0) \n Longitude: \(selectedPinView.annotation?.coordinate.longitude ?? 0.0)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Display Photo Collection", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "showTravelVC", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Remove Marker", style: .destructive, handler: { (_) in
            self.dataController.viewContext.delete(self.selectedPin)
            try? self.dataController.viewContext.save()
        }))
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertView)))
        }
    }
    
    @objc func dismissAlertView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTravelVC" {
            let photoAlbumVC = segue.destination as! PhotoAlbumViewController
            
            photoAlbumVC.dataController = dataController
            photoAlbumVC.pin = selectedPin
            
            let backButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: nil)
            navigationItem.backBarButtonItem = backButton
            
            photoAlbumVC.latitude = CLLocationDegrees(String(format: "%f", (selectedPinView.annotation?.coordinate.latitude)!))
            photoAlbumVC.longitude = CLLocationDegrees(String(format: "%f", (selectedPinView.annotation?.coordinate.longitude)!))
            photoAlbumVC.zoomLevel = self.zoomLevel
            photoAlbumVC.currentRegion = self.currentRegion
        }
    }
    
}


// MARK: - Extension for NSFetchedResultsControllerDelegate Methods

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        for operation in blockOperations {
            operation.start()
        }
        blockOperations.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let newIndex = newIndexPath {
                    let pinToAdd = self?.fetchedResultsController.object(at: newIndex)
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: pinToAdd!.latitude, longitude: pinToAdd!.longitude)
                    self?.mapView.addAnnotation(pointAnnotation)
                }
            }))

        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                let pinToDelete = anObject as! Pin
                for annotaion in self!.mapView!.annotations {
                    if (annotaion.coordinate.latitude == pinToDelete.latitude && annotaion.coordinate.longitude == pinToDelete.longitude) {
                        self?.mapView.removeAnnotation(annotaion)
                    }
                }
            }))
        default:
            break
        }
    }
}
