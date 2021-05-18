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

class TravelLocationsMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Properties
    var annotations = [MKPointAnnotation]()
    var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var selectedPin: MKAnnotationView = MKAnnotationView()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var latitudeDelta: Double = 0.0
    var longitudeDelta: Double = 0.0
    var zoomLevel: MKCoordinateSpan = MKCoordinateSpan()
    var currentRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setUpMapView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapViewLocation()
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
        UserDefaults.standard.synchronize()
    }
    
    func loadMapViewLocation() {
        latitude = UserDefaults.standard.double(forKey: "latitude")
        longitude = UserDefaults.standard.double(forKey: "longitude")
        latitudeDelta = UserDefaults.standard.double(forKey: "latitudeDelta")
        longitudeDelta = UserDefaults.standard.double(forKey: "longitudeDelta")
        centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        zoomLevel = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        currentRegion = MKCoordinateRegion(center: centerCoordinate, span: zoomLevel)
        mapView.setRegion(currentRegion, animated: true)
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
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "New Title"
        annotation.subtitle = "New Detail"
        
        annotations.append(annotation)
        self.mapView.addAnnotations(annotations)
    }
    
}


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
        selectedPin = view
        performSegue(withIdentifier: "showTravelVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTravelVC" {
            let photoAlbumVC = segue.destination as! PhotoAlbumViewController
            
            let backButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: nil)
            navigationItem.backBarButtonItem = backButton
            
            photoAlbumVC.latitude = CLLocationDegrees(String(format: "%f", (selectedPin.annotation?.coordinate.latitude)!))
            photoAlbumVC.longitude = CLLocationDegrees(String(format: "%f", (selectedPin.annotation?.coordinate.longitude)!))
            photoAlbumVC.zoomLevel = self.zoomLevel
            photoAlbumVC.currentRegion = self.currentRegion
        }
    }
    
}

