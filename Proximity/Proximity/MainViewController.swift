//
//  ViewController.swift
//  Proximity
//
//  Created by Christopher Perkins on 10/7/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

class MainViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightButtonView: UIView!
    @IBOutlet weak var claimButton: UIButton!
    
    private var locationManager = CLLocationManager()
    private var locationInfoArray = [LocationInfo]()
    private var webOverlayView: UIView = UIView()
    private var timer: DispatchSourceTimer?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // cling to webview
        self.webView.addSubview(webOverlayView)
        NSLayoutConstraint.clingToViewEdges(view: webOverlayView,
                                            toView: self.webView)
        
        label.text = "Proximity"
        label.setDefaultProperties()
        
        locationInfoArray = LocationInfo.getLocations()
        
        self.startTimer()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupLocationManager()
        
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "noLocationsNearby"), for: .normal)
        //button.addTarget(self, action: #selector(updateCoordinates), for: .touchUpInside)
        self.view.addSubview(button)
        rightButtonView.backgroundColor = UIColor.clear
        NSLayoutConstraint.clingToViewEdges(view: button, toView: rightButtonView)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        self.webOverlayView.removeAllSubviews()
    }
    
    @objc func willEnterForeground() {
        self.setupLocationManager()
    }
    
    // MARK: GET/POST Requests
    
    // Requests the current location info for this location
    private func getRequestForLocation(location: CLLocation) {
        webOverlayView.removeAllSubviews()
        webOverlayView.alpha = 0
        
        var request = URLRequest(url: URL(string: String(format: (Constants.baseUrl + "/url/%d/%d"),
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
            
            var couldNotCompleteRequest = false
            if responseString != nil {
                let urlString = String(describing: JSON.init(parseJSON: responseString!)["url"])
                
                let url = URL(string: urlString)
                if urlString == "" {
                    couldNotCompleteRequest = true
                    
                    DispatchQueue.main.sync {
                        let button = UIButton()
                        button.setImage(#imageLiteral(resourceName: "locationClaim"), for: .normal)
                        button.addTarget(self, action: #selector(self.promptForURLView), for: .touchUpInside)
                        
                        self.webOverlayView.addSubview(button)
                        
                        button.translatesAutoresizingMaskIntoConstraints = false
                        
                        NSLayoutConstraint(item: self.webOverlayView,
                                           attribute: .centerX,
                                           relatedBy: .equal,
                                           toItem: button,
                                           attribute: .centerX,
                                           multiplier: 1,
                                           constant: 0).isActive = true
                        NSLayoutConstraint(item: self.webOverlayView,
                                           attribute: .centerY,
                                           relatedBy: .equal,
                                           toItem: button,
                                           attribute: .centerY,
                                           multiplier: 1,
                                           constant: 0).isActive = true
                        NSLayoutConstraint(item: self.webOverlayView,
                                           attribute: .width,
                                           relatedBy: .equal,
                                           toItem: button,
                                           attribute: .width,
                                           multiplier: 1.5
                            ,
                                           constant: 0).isActive = true
                        NSLayoutConstraint(item: button,
                                           attribute: .width,
                                           relatedBy: .equal,
                                           toItem: button,
                                           attribute: .height,
                                           multiplier: 1,
                                           constant: 0).isActive = true
                    }
                } else if url != nil {
                    DispatchQueue.main.sync {
                        self.webView.loadRequest(URLRequest(url: url!))
                    }
                } else {
                    couldNotCompleteRequest = true
                }
            } else {
                couldNotCompleteRequest = true
            }
            
            if couldNotCompleteRequest {
                self.webOverlayView.alpha = 1
                self.webView.loadHTMLString("", baseURL: nil)
            }
            
        }
        task.resume()
    }
    
    // Posts a url to the given coordinates
    private func postRequestForLocation(location: CLLocation, urlString: String) {
        var request = URLRequest(url: URL(string: String(format: (Constants.baseUrl + "/url/%d/%d"),
                                                         Int(location.coordinate.latitude * Constants.multiplier),
                                                         Int(location.coordinate.longitude * Constants.multiplier)))!)
        request.httpMethod = "POST"
        
        let json: JSON = JSON.init(parseJSON: ("{\"url\": \"" + urlString + "\"}"))
        
        do {
            let data:Data = try json.rawData()
            request.httpBody = data
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        } catch {}
        
        
        request.value(forHTTPHeaderField: "Content-Type: application/json")
        
        
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
            print(responseString ?? "empty returned")
        }
        task.resume()
    }

    
    // MARK: Location manager stuff. Ew.
    
    // set's up the location manager
    @objc private func setupLocationManager() {
        self.webOverlayView.removeAllSubviews()
        self.webOverlayView.alpha = 1
        
        // Ask for authorization from the User.
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            
            if status == .authorizedAlways {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                locationManager.startMonitoringSignificantLocationChanges()
                self.webOverlayView.alpha = 0
                
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
                self.createNoLocationButton()
            }
        } else {
            let alert = UIAlertController(title: "Location Services Disabled",
                                          message: "Please enable Location Services.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .cancel,
                                         handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            self.createNoLocationButton()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.setupLocationManager()
    }
    
    // Event function for NoLocation pressed
    private func createNoLocationButton() {
        webOverlayView.removeAllSubviews()
        
        let button = UIButton()
        self.webOverlayView.addSubview(button)
        NSLayoutConstraint.clingToViewEdges(view: button, toView: self.webView)
        button.setImage(#imageLiteral(resourceName: "noLocationPermission"), for: .normal)
        button.addTarget(self, action: #selector(setupLocationManager), for: .touchUpInside)
    }
    
    @objc private func promptForURLView() {
        let alert = UIAlertController(title: "Web Site for this Location?",
                                      message: "Please enter a website to display at this location",
                                      preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (textField) in
            textField.text = ""
            textField.placeholder = "Place valid URL here"
        })
        
        alert.addAction(UIAlertAction(title: "Create!",
                                      style: .default,
                                      handler: {
                                        (_) -> Void in
                                        let text = alert.textFields![0].text
                                        if text != nil && text != "" {
                                            self.postRequestForLocation(location: self.locationManager.location!,
                                                                        urlString: text!)
                                        }
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Repeating queue
    
    private func startTimer() {
        let queue = DispatchQueue(label: "com.firm.app.timer", attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(20), leeway: .seconds(1))
        
        timer?.setEventHandler { [weak self] in
            
            if self != nil {
                if (self!.locationManager.location) != nil {
                    self!.getRequestForLocation(location: self!.locationManager.location!)
                }
            }
        }
        
        timer?.resume()
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}

