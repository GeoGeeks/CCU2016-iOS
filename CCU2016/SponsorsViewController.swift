//
//  SponsorsViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 29/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class SponsorsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var sponsors:[Sponsor]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.populateCollection()
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sponsors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("sponsorCell", forIndexPath: indexPath) as! PartnerCell
        cell.image.image =  UIImage(named: self.sponsors[indexPath.row].imageURL)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.sponsors[indexPath.row].siteURL != nil{
            let url = NSURL(string: self.sponsors[indexPath.row].siteURL)!
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func populateCollection(){
        self.sponsors = []
        
        let eptisa = Sponsor()
        eptisa.imageURL = "EPTISA"
        eptisa.siteURL = "http://www.eptisa.com/es/"
        self.sponsors.append(eptisa)
        
//        let esrisac = Sponsor()
//        esrisac.imageURL = "ESRISAC"
//        self.sponsors.append(esrisac)
        
        let geofields = Sponsor()
        geofields.imageURL = "GEOFIELDS"
        self.sponsors.append(geofields)
        
        let handg = Sponsor()
        handg.imageURL = "HandG"
        handg.siteURL = "http://www.hyg.com.co/web/"
        self.sponsors.append(handg)
        
        let harris = Sponsor()
        harris.imageURL = "HARRIS"
        harris.siteURL = "https://www.harris.com/"
        self.sponsors.append(harris)
        
        let here = Sponsor()
        here.imageURL = "HERE"
        here.siteURL = "https://company.here.com/here/"
        self.sponsors.append(here)
        
        let multiprocesos = Sponsor()
        multiprocesos.imageURL = "MULTIPROCESOS"
        multiprocesos.siteURL = "http://multiprocesos.com/"
        self.sponsors.append(multiprocesos)
        
        let osisoft = Sponsor()
        osisoft.imageURL = "OSISOFT"
        osisoft.siteURL = "http://www.osisoft.com/"
        self.sponsors.append(osisoft)
        
        let procalculo = Sponsor()
        procalculo.imageURL = "PROCALCULO"
        procalculo.siteURL = "http://www.procalculo.com/"
        self.sponsors.append(procalculo)
        
        let servinformacion = Sponsor()
        servinformacion.imageURL = "SERVINFORMACION"
        servinformacion.siteURL = "http://servinformacion.com/servinformacion/inicio"
        self.sponsors.append(servinformacion)
        
        let skaphe = Sponsor()
        skaphe.imageURL = "SKAPHE"
        skaphe.siteURL = "http://db.skaphe.com/skp/#"
        self.sponsors.append(skaphe)
        
        let smartCloud = Sponsor()
        smartCloud.imageURL = "SMARTCLOUD"
        smartCloud.siteURL = "http://www.smart-cloud.co/"
        self.sponsors.append(smartCloud)
        
        let trimble = Sponsor()
        trimble.imageURL = "TRIMBLE"
        trimble.siteURL = "http://www.trimble.com/"
        self.sponsors.append(trimble)
        
        let ungis = Sponsor()
        ungis.imageURL = "UNIGIS"
        self.sponsors.append(ungis)
        
        let versatile = Sponsor()
        versatile.imageURL = "VERSATILE"
        self.sponsors.append(versatile)
        
        self.collectionView.reloadData()
    }
    
    class Sponsor{
        var imageURL: String!
        var siteURL: String!
    }
}
