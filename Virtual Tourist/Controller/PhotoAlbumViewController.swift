//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Mehrdad on 2021-05-03.
//  Copyright © 2021 Udacity. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - Properties
    var latitude: Double!
    var longitude: Double!
    var zoomLevel: MKCoordinateSpan!

    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Latitude: \(String(describing: latitude)), Longitude: \(String(describing: longitude))")
        
        loadMapViewLocation()
    }
    
    
    // MARK: - Methods
    func loadMapViewLocation() {
        
        let mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let currentRegion = MKCoordinateRegion(center: mapCenter, span: zoomLevel)
        mapView.setRegion(currentRegion, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
