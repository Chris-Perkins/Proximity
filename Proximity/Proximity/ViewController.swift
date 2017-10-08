//
//  ViewController.swift
//  Proximity
//
//  Created by Christopher Perkins on 10/7/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightButtonView: UIView!
    
    private var locationManager = CLLocationManager()
    private var locationInfoArray = [LocationInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Proximity"
        label.setDefaultProperties()
        
        locationInfoArray = LocationInfo.getLocations()
        
        webView.loadRequest(URLRequest(url: URL(string: "https://www.mcdonalds.com/us/en-us.html")!))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setupLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupLocationManager() {
        
        // Ask for authorization from the User.
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            
            if status == .authorizedAlways {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                
            } else if status == .notDetermined {
                self.locationManager.requestAlwaysAuthorization()
            } else if status == .denied || status == .restricted {
                let alert =
                    UIAlertController(title: "Location Permissions Required",
                                      message: "This application requires location permissions to determine where you are. Give the application Location Permissions?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: {
                                                (_) -> Void in
                                                UIApplication.shared.open(
                                                    URL(string: UIApplicationOpenSettingsURLString)!)
                })
                let cancelAction =
                    UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Location Services Disabled",
                                          message: "Please enable Location Services.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok",
                                         style: .cancel,
                                         handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) -> CLLocation {
        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        return CLLocation(latitude: locValue.latitude,
                          longitude: locValue.longitude)
    }
}

