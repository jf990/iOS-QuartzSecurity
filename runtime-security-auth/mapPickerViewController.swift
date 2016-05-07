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

    private var testData:TestData = TestData.sharedTestData;
    private let reuseIdentifier = "BasemapCell"
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    internal var selectedItem:Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    internal func getSelectedItemIndex() -> Int {
        return self.selectedItem
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedItem = indexPath.row
        self.performSegueWithIdentifier("unwindToMain", sender: self)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! mapPickerCollectionViewCell
        cell.backgroundColor = UIColor.lightGrayColor()
        let portalItemInfo = testData.portalItems[indexPath.row]
        cell.titleLabel.text = portalItemInfo[1]
        cell.imageView.image = UIImage(named: portalItemInfo[0])
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testData.portalItems.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func basemapForIndexPath(indexPath: NSIndexPath) -> String {
        return testData.portalItems[indexPath.row][0]
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
}
