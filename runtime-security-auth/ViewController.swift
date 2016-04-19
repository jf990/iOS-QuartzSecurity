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
    var portalItemId:String = "caf7718cd2974a2e997cf98aa005ef25"
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var protocolSelecter: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessage.text = ""
        authenticationManager.delegate = self
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
            errorMessage.text = "Using default challenge handler"
            challenge.continueWithDefaultHandling()
            
        case AGSAuthenticationChallengeType.UsernamePassword:
            errorMessage.text = "Overriding challenge handler for name/password"
            
        default:
            errorMessage.text = "Unknown challenge handler"
        }
    }
    
    func loadMap () {
        errorMessage.text = "Loading map..."
        self.mapView.map = self.createMapFromPortalItem()
        if self.mapView.map == nil {
            errorMessage.text = "Could not load map"
        } else {
            self.mapView.map?.loadWithCompletion() { (error : NSError?) in
                if error == nil {
                    self.errorMessage.text = ""
                } else {
                    self.errorMessage.text = "Error loading map (\(error!.code)): \(error!.localizedDescription)"
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
    
    @IBAction func protocolChanged(sender: UISegmentedControl) {
        errorMessage.text = "Using " + self.stringFromProtocolSelection() + " authentication."
    }
    
    @IBAction func loginButtonAction(sender: AnyObject) {
        
        // login or logout
        if isLoggedIn {
            
        } else {
            errorMessage.text = "Trying to login with " + self.stringFromProtocolSelection() + " authentication"
        }
    }
}

