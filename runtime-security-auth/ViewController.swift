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

    var activeChallenge:AGSAuthenticationChallenge?
    var portal:AGSPortal!
    var portalItem:AGSPortalItem!
    var authenticationManager:AGSAuthenticationManager = AGSAuthenticationManager.sharedAuthenticationManager()
    var isLoggedIn:Bool = false
    var isLoggingIn:Bool = false
    var testData:TestData = TestData.sharedTestData;
    var lastSelectedPortalItem:Int = 0
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var loginUserName: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var loginActivity: UIActivityIndicatorView!
    @IBOutlet weak var loginViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginViewWidthConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authenticationManager.delegate = self
        self.setupOAuth()
        self.loadMap()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.logAppInfo("")
        self.hideLoginView(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * didReceiveAuthenticationChallenge is called by AGSAuthenticationManager when it needs to ask the user
     * to authenticate.
     */
    func authenticationManager(authenticationManager: AGSAuthenticationManager, didReceiveAuthenticationChallenge challenge: AGSAuthenticationChallenge) {
        
        self.logAppInfo("didReceiveAuthenticationChallenge asking to login with " + self.authenticationTypeFromChallengeType(challenge.type) + " authentication")
        self.activeChallenge = challenge
        switch challenge.type {
        case AGSAuthenticationChallengeType.OAuth,
             AGSAuthenticationChallengeType.ClientCertificate,
             AGSAuthenticationChallengeType.UntrustedHost:
            self.logAppInfo("Using default challenge handler")
            self.isLoggingIn = true
            if self.testData.useCustomLoginView {
                self.showLoginView()
            } else {
                self.activeChallenge!.continueWithDefaultHandling()
            }
            
        case AGSAuthenticationChallengeType.UsernamePassword:
            self.logAppInfo("Overriding challenge handler for name/password")
            self.isLoggingIn = true
            if self.testData.useCustomLoginView {
                self.showLoginView()
            } else {
                self.activeChallenge!.continueWithDefaultHandling()
            }
            
        default:
            self.logAppInfo("Unknown challenge handler")
        }
    }
    
    func setupOAuth() {
        let oauthConfiguration = AGSOAuthConfiguration(portalURL: NSURL(string: self.testData.portalURL)!, clientID: self.testData.clientId, redirectURL: nil)
        authenticationManager.OAuthConfigurations.addObject(oauthConfiguration)
    }

    /**
     * Get a Map and assign it to the MapView
     */
    func loadMap () {
        self.mapView.map = self.createMapFromTestData()
        if self.mapView.map == nil {
            self.logAppInfo("Could not create map")
        } else {
            self.mapView.map?.loadWithCompletion() { (error : NSError?) in
                if error == nil {
                    self.logAppInfo("")
                } else {
                    self.logAppInfo("Error loading map (\(error!.code)): \(error!.localizedDescription)")
                    
                    // just in case if the token is bad then attempt to clear the credentials
                    if error!.code == 499 {
                        self.userIsLoggedOut()
                    }
                }
            }
        }
    }
    
    /**
     * Use this function to create a Map from the test data structure. It gives us the opportunity to
     * decide which map to create, and therefore which authentication flow to follow.
     */
    func createMapFromTestData () -> AGSMap {
        let portalItemId:String = self.testData.portalItems[self.lastSelectedPortalItem][2]
        if (self.testData.portalURL.characters.count > 0 && portalItemId.characters.count > 0) {
            return self.createMapFromPortalItem(portalItemId, loginRequired: self.testData.forceUserToLogin)
        } else {
            return self.createMapFromBaseMap()
        }
    }

    /**
     * Create a Map from the portal item held in the test data structure.
     */
    func createMapFromPortalItem (portalItemId:String, loginRequired:Bool) -> AGSMap {
        
        let portal = AGSPortal (URL: NSURL(string: self.testData.portalURL)!, loginRequired: loginRequired)
        portal.loadWithCompletion() { (error) in
            if error == nil {
                if portal.loadStatus == AGSLoadStatus.Loaded {
                    self.logAppInfo("Loaded portal item " + portalItemId + ", maybe the user is logged in?")
                    // Here's a problem: loading the map succeeds but we don't know if the authentication flow was invoked. This
                    // forces our app to manage it's own version of user log-in state and guess we have it right.
                    if self.isLoggingIn {
                        self.userIsLoggedIn()
                    }
                } else {
                    self.logAppInfo("There was an error loading the portal item")
                }
            } else {
                self.logAppInfo("There was an error loading the portal item: " + error.debugDescription)
            }
            self.isLoggingIn = false
        }
        let portalItem = AGSPortalItem(portal: portal, itemID: portalItemId)
        return AGSMap(item: portalItem)
    }
    
    /**
     * Create a Map from a pre-defined basemap.
     */
    func createMapFromBaseMap () -> AGSMap {
        let basemap:AGSBasemap = AGSBasemap.lightGrayCanvasBasemap()
        return AGSMap(basemap: basemap)
    }
    
    /**
     * Map an AGS authentication challenge type id into a human readable string to show in the UI. We choose
     * to use strings that match the documentation.
     */
    func authenticationTypeFromChallengeType (challengeType:AGSAuthenticationChallengeType) -> String {

        switch challengeType {
        case AGSAuthenticationChallengeType.OAuth:
            return "OAuth"
        case AGSAuthenticationChallengeType.UsernamePassword:
            return "ArcGIS Token"
        case AGSAuthenticationChallengeType.UntrustedHost:
            return "HTTP"
        case AGSAuthenticationChallengeType.ClientCertificate:
            return "PKI"
        default:
            return "unknown"
        }
    }

    func logAppInfo (message: String) {
        self.errorMessage.text = message
        if message != "" {
            NSLog(message)
        }
    }
    
    /**
     * Do things required by our app to maintain the user in a logged in state
     */
    func userIsLoggedIn () {
        self.isLoggedIn = true
        self.loginButton.setTitle("Log out", forState: UIControlState.Normal)
    }
    
    /**
     * Do things required by our app to log out the user
     */
    func userIsLoggedOut () {
        self.authenticationManager.credentialCache.removeAllCredentials()
        self.isLoggedIn = false
        self.loginButton.setTitle("Log in", forState: UIControlState.Normal)
    }
    
    /**
     * Show the login form
     */
    func showLoginView () {
        self.loginView.hidden = false
        self.loginActivity.hidden = true
        self.loginView.alpha = 0
        self.loginTitle.alpha = 0
        self.loginUserName.alpha = 0
        self.loginPassword.alpha = 0
        
        UIView.animateWithDuration(0.4, delay: 0.1, options: .CurveEaseOut, animations: {
            self.loginView.alpha = 1
            self.loginTitle.alpha = 1
            self.loginUserName.alpha = 1
            self.loginPassword.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: { finished in
                print("showing Login view")
        })
    }
    
    /**
     * Hide the login form with or without animation
     */
    func hideLoginView (animate:Bool) {
        self.loginActivity.stopAnimating()
        self.loginActivity.hidden = true
        if (animate) {
            UIView.animateWithDuration(0.4, delay: 0.1, options: .CurveEaseOut, animations: {
                self.loginView.alpha = 0
                self.loginTitle.alpha = 0
                self.loginUserName.alpha = 0
                self.loginPassword.alpha = 0
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.loginView.hidden = true
            })
        } else {
            self.loginView.hidden = true
        }
    }
    
    /**
     * Animate activity view to show we are waiting for the server to reply
     */
    func startLoginActivity () {
        self.loginActivity.hidden = false
        self.loginActivity.startAnimating()
    }
    
    @IBAction func mapSelectAction(sender:AnyObject) {
        // IB segue automatically handles the transition
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        let itemPicked:Int = (segue.sourceViewController as! mapPickerViewController).getSelectedItemIndex()
        if itemPicked != -1 && itemPicked != self.lastSelectedPortalItem {
            self.lastSelectedPortalItem = itemPicked
            self.loadMap()
        }
    }
    
    @IBAction func loginCloseAction(sender: AnyObject) {
        self.hideLoginView(true)
        if self.activeChallenge != nil {
            self.activeChallenge!.cancel()
        }
    }
    
    @IBAction func loginButtonAction(sender: AnyObject) {
        
        if isLoggedIn {
            // logout
            self.userIsLoggedOut()
        } else {
            // login
            if self.loginView.hidden {
                self.showLoginView()
            } else if (self.loginActivity.isAnimating()) {
                self.hideLoginView(true)
            } else {
                self.startLoginActivity()
                let credential = AGSCredential(user: loginUserName.text!, password: loginPassword.text!)
                if self.activeChallenge != nil {
                    self.logAppInfo("Trying to login for " + self.authenticationTypeFromChallengeType((self.activeChallenge?.type)!) + " authentication")
                    self.activeChallenge!.continueWithCredential(credential)
                } else {
                    // Here we should do an unsolicited login
                    self.logAppInfo("THERE IS NO WAY TO LOG IN!")
                }
            }
        }
    }
}

