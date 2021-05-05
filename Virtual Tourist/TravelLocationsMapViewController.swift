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
    var center: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        // mapView.setCenter(center, animated: true)
    }

    
    // MARK: - Actions
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
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
    
}


extension TravelLocationsMapViewController {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        center = mapView.centerCoordinate
        
//        let currentCenter = mapView.centerCoordinate
//        LocationSt
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        performSegue(withIdentifier: "showTravelVC", sender: self)
    }
    
}

