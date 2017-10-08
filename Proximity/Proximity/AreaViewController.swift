//
//  AreaViewController.swift
//  Proximity
//
//  Created by Christopher Perkins on 10/7/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import CoreLocation
import GoogleMaps
import GooglePlaces

class AreaViewController: UIViewController, CLLocationManagerDelegate {
    let size:Int32 = 10
    
    
    //Map
    
    
    
    var map: GMSMapView?
    
    let tileLayer = GMSURLTileLayer()
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 10)
        map = GMSMapView.map(withFrame: .zero, camera: camera)
        view = map
        
        tileLayer.map = map
        tileLayer.zIndex = size
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        
        
        let location = locations[0]
        
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        //let region:GMSCoordinateBounds = GMSCoordinateBounds(coordinate: myLocation, coordinate: span)
        
        //map.setRegion(region, animated: true)
        //self.map.showsUserLocation = true
    }
    
    @IBOutlet weak var locationGrid: UICollectionView!
}
