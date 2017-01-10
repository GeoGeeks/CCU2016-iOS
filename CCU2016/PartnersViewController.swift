//
//  PartnersViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 29/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class PartnersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var partners:[PartnerItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        partners = []
        
        self.populateCollection()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return partners.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("PartnerCell", forIndexPath: indexPath) as! PartnerCell
        //cell.image.image = UIImage(named: "no-thumb.jpg")
        cell.image.image = UIImage(named: partners[indexPath.row].partnerImage)
        cell.url = partners[indexPath.row].partnerUrl
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PartnerCell
        let url = NSURL(string: cell.url)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func populateCollection(){
        for index in 1...21{
            let partner = PartnerItem()
            partner.partnerId = "partner" + String(index)
            partner.partnerImage = "no-thumb.jpg"
            partner.partnerUrl = "http://esri.co"
            partners.append(partner)
        }
        collectionView.reloadData()
    }
}
