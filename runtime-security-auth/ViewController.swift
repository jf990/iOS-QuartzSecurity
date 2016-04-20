//
//  ViewController.swift
//  runtime-security-auth
//  A View Controller to demonstrate UI related to Authentication procedures.
//
//  Created by John Foster on 4/18/16.
//  Copyright © 2016 John Foster. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, AGSAuthenticationManagerDelegate {

    var credential:AGSCredential!
    var portal:AGSPortal!
    var portalItem:AGSPortalItem!
    var authenticationManager:AGSAuthenticationManager = AGSAuthenticationManager.sharedAuthenticationManager()
    var isLoggedIn:Bool = false
    var portalItemId:String = "c0edf8284710428abea81b76200a190f"
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var protocolSelecter: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logAppInfo("")
        self.authenticationManager.delegate = self
        self.loadMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didReceiveAuthenticationChallenge(authenticationManager:AGSAuthenticationManager, challenge:AGSAuthenticationChallenge) {
        
        switch challenge.type {
        case AGSAuthenticationChallengeType.OAuth,
             AGSAuthenticationChallengeType.ClientCertificate,
             AGSAuthenticationChallengeType.UntrustedHost:
            self.logAppInfo("Using default challenge handler")
            challenge.continueWithDefaultHandling()
            
        case AGSAuthenticationChallengeType.UsernamePassword:
            self.logAppInfo("Overriding challenge handler for name/password")
            challenge.continueWithDefaultHandling()
            
        default:
            self.logAppInfo("Unknown challenge handler")
        }
    }
    
    func loadMap () {
        self.logAppInfo("Loading map...")
        self.mapView.map = self.createMapFromPortalItem()
        if self.mapView.map == nil {
            self.logAppInfo("Could not load map")
        } else {
            self.mapView.map?.loadWithCompletion() { (error : NSError?) in
                if error == nil {
                    self.logAppInfo("")
                } else {
                    self.logAppInfo("Error loading map (\(error!.code)): \(error!.localizedDescription)")
                }
            }
        }
    }

    func createMapFromPortalItem () -> AGSMap {
        let portal = AGSPortal (URL: NSURL(string: "http://www.arcgis.com")!, loginRequired: false)
        let portalItem = AGSPortalItem(portal: portal, itemID: self.portalItemId)
        return AGSMap(item: portalItem)
    }
    
    func authenticationTypeFromProtocolSelection () -> AGSAuthenticationChallengeType {

        // what is AGSAuthenticationType.kerberos? and why no OAuth?
        
        switch protocolSelecter.selectedSegmentIndex {
        case 0:
            return AGSAuthenticationChallengeType.OAuth
        case 1:
            return AGSAuthenticationChallengeType.UsernamePassword
        case 2:
            return AGSAuthenticationChallengeType.UntrustedHost
        case 3:
            return AGSAuthenticationChallengeType.ClientCertificate
        default:
            return AGSAuthenticationChallengeType.Unknown
        }
    }

    func stringFromProtocolSelection () -> String {
        
        switch protocolSelecter.selectedSegmentIndex {
        case 0:
            return "OAuth"
        case 1:
            return "ArcGIS Token"
        case 2:
            return "HTTP"
        case 3:
            return "PKI"
        default:
            return ""
        }
    }
    
    func logAppInfo (message: String) {
        self.errorMessage.text = ""
        if message != "" {
            NSLog(message)
        }
    }
    
    @IBAction func protocolChanged(sender: UISegmentedControl) {
        self.logAppInfo("Using " + self.stringFromProtocolSelection() + " authentication.")
    }
    
    @IBAction func loginButtonAction(sender: AnyObject) {
        
        // login or logout
        if isLoggedIn {
            
        } else {
            self.logAppInfo("Trying to login with " + self.stringFromProtocolSelection() + " authentication")
        }
    }
}

