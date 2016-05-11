//
//  mapPickerViewController.swift
//  runtime-security-auth
//
//  Created by John Foster on 5/5/16.
//  Copyright © 2016 John Foster. All rights reserved.
//
// Show a collection of available basemaps. The user chooses 1 and we return.
//

import UIKit
import ArcGIS



class mapPickerViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let reuseIdentifier = "BasemapCell"
    let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    let testData:TestData = TestData.sharedTestData;
    var selectedItem:Int = -1
    var queryResults:NSArray? = nil

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var groupUIView: UIView!
    @IBOutlet weak var infoMessage: UILabel!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.testData.isUserLoggedIn {
            // initiate a query to the portal to get the possible basemaps
            self.updateUserMessageWithActivity("Getting your basemaps")
            let basemapQuery = self.testData.portal!.portalInfo?.basemapGalleryGroupQuery
            if basemapQuery != nil {
                let queryParams = AGSPortalQueryParams(query: basemapQuery!)
                self.testData.portal.findItemsWithQueryParams(queryParams, completion: { (portalResultSet, error) in
                    if error != nil {
                        self.updateUserMessageStopActivity("Error loading basemaps: (\(error!.code)): \(error!.localizedDescription)")
                    } else if portalResultSet!.results != nil {
                        self.queryResults = portalResultSet!.results
                        if self.queryResults!.count == 0 {
                            self.updateUserMessageStopActivity("No basemaps were found on your account")
                        } else {
                            self.updateUserMessageStopActivity("")
                        }
                        self.collectionView!.reloadData()
                    } else {
                        // neither error nor results?
                        self.updateUserMessageStopActivity("You have no basemaps")
                    }
                })
            }
        } else {
            self.updateUserMessage("")
            self.hideFeedbackUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.queryResults = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    internal func getSelectedItemIndex() -> Int {
        return self.selectedItem
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedItem = indexPath.row
        self.closeView()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! mapPickerCollectionViewCell
        cell.backgroundColor = UIColor.lightGrayColor()
        if self.queryResults != nil {
            let portalItemInfo:AGSPortalItem = self.queryResults![indexPath.row] as! AGSPortalItem
            cell.titleLabel.text = portalItemInfo.title
            cell.imageView.image = UIImage(named: "dark_gray_canvas")
        } else {
            let portalItemInfo = testData.portalItems[indexPath.row]
            cell.titleLabel.text = portalItemInfo[1]
            cell.imageView.image = UIImage(named: portalItemInfo[0])
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.queryResults != nil {
            return self.queryResults!.count
        } else {
            return testData.portalItems.count
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func basemapForIndexPath(indexPath: NSIndexPath) -> String {
        if self.queryResults != nil {
            return self.queryResults![indexPath.row] as! String
        } else {
            return testData.portalItems[indexPath.row][0]
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 140, height: 93 + 18)
    }
    
    func showFeedbackUI () {
        self.groupUIView.hidden = false
    }
    
    func hideFeedbackUI () {
        self.loadingActivity.stopAnimating()
        self.groupUIView.hidden = true
    }
    
    func updateUserMessage (message: String) {
        if self.groupUIView.hidden {
            self.showFeedbackUI()
        }
        self.infoMessage.text = message
    }
    
    func updateUserMessageWithActivity (message: String) {
        self.updateUserMessage(message)
        self.loadingActivity.hidden = false
        self.loadingActivity.startAnimating()
    }
    
    func updateUserMessageStopActivity (message: String) {
        self.updateUserMessage(message)
        self.loadingActivity.stopAnimating()
        self.loadingActivity.hidden = true
    }

    func closeView () {
        self.performSegueWithIdentifier("unwindToMain", sender: self)
    }
    
    @IBAction func cancelButtonAction (sender: AnyObject) {
        self.closeView()
    }
}
