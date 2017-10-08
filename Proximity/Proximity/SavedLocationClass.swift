//
//  SavedLocationClass.swift
//  Proximity
//
//  Created by Christopher Perkins on 10/7/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationInfo: NSObject {
    
    // View properties
    
    private var location: CLLocation
    private var websiteURL: URL
    private var radiusInMeters: CGFloat
    
    // view inits
    
    init(location: CLLocation, websiteURL: URL, radiusInMeters: CGFloat) {
        self.location = location
        self.websiteURL = websiteURL
        self.radiusInMeters = radiusInMeters
        
        super.init()
    }
    
    // encapsulated methods
    
    public func getLocation() -> CLLocation {
        return self.location
    }
    
    public func getURL() -> URL {
        return self.websiteURL
    }
    
    public func getRadiusInMeters() -> CGFloat {
        return self.getRadiusInMeters()
    }
}
