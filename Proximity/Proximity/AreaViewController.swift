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
import SwiftyJSON

class AreaViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    //Map
    @IBOutlet weak var map: MKMapView!
    var tileOverlay:MKTileOverlay?
    var gridOverlay:MKTileOverlay = GridTileOverlay()
    var gridData: JSON?
    
    private var timer: DispatchSourceTimer?
    
    @IBAction func backButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.isZoomEnabled = false
        map.isScrollEnabled = false
        map.isRotateEnabled = false
        map.isUserInteractionEnabled = true
        
        gridOverlay = GridTileOverlay()
        gridOverlay.canReplaceMapContent = false
        
        map.add(gridOverlay)
        map.delegate = self


        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        startTimer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(1 / Constants.multiplier, 1 / Constants.multiplier)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        /*if([overlay isKindOfClass:[MKTileOverlay class]]) {
            MKTileOverlay *tileOverlay = (MKTileOverlay *)overlay;
            MKTileOverlayRenderer *renderer = nil;
            if([tileOverlay isKindOfClass:[GridTileOverlay class]]) {
                #if ( OFFLINE_USE_CUSTOM_OVERLAY_RENDERER == 1 )
                    renderer = [[GridTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
                #else
                    renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
                #endif
            } else {
                //if(self.overlayType==CustomMapTileOverlayTypeGoogle) {
                renderer = [[WatermarkTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
                /*} else {
                 renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
                 }*/
            }*/
        var renderer:MKTileOverlayRenderer
        if (overlay as? MKTileOverlay) != nil {
            tileOverlay = (overlay as! MKTileOverlay)
            if let gridTileOverlay = overlay as? GridTileOverlay {
                renderer = GridTileOverlayRenderer(tileOverlay: gridTileOverlay)
            }else{
                renderer = WatermarkTileOverlayRenderer(tileOverlay: tileOverlay!)
            }
            
            renderer.alpha = 0.5
            
            return renderer
        } else {
            renderer = (overlay as! GridTileOverlayRenderer)
            return renderer
        }
    }

    // Requests the current location info for this location
    private func getRequestForLocation(location: CLLocation) {
        var request = URLRequest(url: URL(string: String(format: (Constants.baseUrl + "/area/%d/%d"),
                                                         Int(location.coordinate.latitude * Constants.multiplier),
                                                         Int(location.coordinate.longitude * Constants.multiplier)))!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print(responseString ?? "NIL RESPONSE")
            if responseString != nil {
                let json = JSON.init(parseJSON: responseString!)
                
                DispatchQueue.main.async {
                    self.gridData = json
                    
                    for key in json {
                        for key2 in key.1 {
                            print(key2.0)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(key.0.floatValue!) / Constants.multiplier,
                                                                           longitude: Double(key2.0.floatValue!) / Constants.multiplier)
                            
                            annotation.subtitle = json[key.0][key2.0].string!
                            self.map.addAnnotation(annotation)
                        }
                    }
                    
                    //for key in json.array
                }
            }
        }
        task.resume()
    }
    
    
    private func startTimer() {
        let queue = DispatchQueue(label: "com.firm.app.timer", attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(20), leeway: .seconds(1))
        
        timer?.setEventHandler { [weak self] in
            
            if self != nil {
                if (self!.manager.location) != nil {
                    self!.getRequestForLocation(location: self!.manager.location!);
                }
            }
        }
        
        timer?.resume()
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func getCoordinate(x: Double, y: Double) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
}
