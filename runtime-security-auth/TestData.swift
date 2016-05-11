//
//  TestData.swift
//  runtime-security-auth
//
//  Created by John Foster on 5/3/16.
//  Copyright © 2016 John Foster. All rights reserved.
//
// A singleton object holding the data we use to test. This keeps it separated from the test code.
//

import Foundation

public class TestData : NSObject {
    
    static let sharedTestData = TestData()
    private override init() {} // make sure no one outside can init this object.
    
    var isUserLoggedIn = false
    
    let forceUserToLogin = false
    let useCustomLoginView = true
    let portalURL:String = "http://www.arcgis.com"
    let clientId:String = "nr3zJGlmQKOqwo5O"
    
    // A list of basemaps on my AGOL account
    // "image", "title", "itemId"
    let portalItems: Array = [
        ["Imagery_Labels_Trans", "Imagery With Labels", "d802f08316e84c6592ef681c50178f17"], // Esri imagery w/labels
        ["relief_labels",        "Light Gray Canvas",   "8b3d38c0819547faa83f7b7aca80bd76"], // Esri light gray canvas basemap
        ["dark_gray_canvas",     "Dark Gray Canvas",    "8b3d38c0819547faa83f7b7aca80bd76"], // Esri dark gray canvas basemap
        ["world_street_map",     "Streets",             "8bf7167d20924cbf8e25e7b11c7c502c"], // Esri streets map
        ["natgeo",               "National Geographic", "d94dcdbe78e141c2b2d3a91d5ca8b9c9"], // National Geographics map
        ["desktopapp",           "Private",             "c0edf8284710428abea81b76200a190f"], // my basemap
        ["transportation",       "Transportation",      "caf7718cd2974a2e997cf98aa005ef25"], // transportation map I did not share, generates error 499
        ["hiking",               "Red Rocks Hike",      "fde57456ec8e413cb92acfca35bd820b"]  // hiking map shared with everyone, generates error 8
        ]
}
