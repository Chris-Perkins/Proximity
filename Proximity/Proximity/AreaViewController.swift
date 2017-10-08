//
//  AreaViewController.swift
//  Proximity
//
//  Created by Christopher Perkins on 10/7/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

class AreaViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    //Map
    @IBOutlet weak var map: MKMapView!
    var tileOverlay:MKTileOverlay?
    var gridOverlay:MKTileOverlay = GridTileOverlay()

    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.isZoomEnabled = false
        map.isScrollEnabled = false
        map.isUserInteractionEnabled = false
        
        gridOverlay = GridTileOverlay()
        gridOverlay.canReplaceMapContent = false
        map.add(gridOverlay)
        map.delegate = self

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        return GridTileOverlayRenderer(overlay: overlay)
    }

}
