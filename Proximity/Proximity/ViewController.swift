//
//  ViewController.swift
//  Proximity
//
//  Created by Christopher Perkins on 10/7/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var label: UILabel!
    
    private var locationHelper = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Proximity"
        label.setDefaultProperties()
        
        webView.loadRequest(URLRequest(url: URL(string: "https://www.mcdonalds.com/us/en-us.html")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

