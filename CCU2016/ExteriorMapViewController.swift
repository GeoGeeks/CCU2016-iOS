//
//  ExteriorMapViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 21/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class ExteriorMapViewController:
UIViewController,
AGSMapViewLayerDelegate,
UISearchBarDelegate,
AGSLocatorDelegate,
AGSWebMapDelegate,
AGSMapViewTouchDelegate,
AGSCalloutDelegate {
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var loadingMap: UIActivityIndicatorView!
    var webMap: AGSWebMap!
    var webMapId: String!
    
    var graphicLayer:AGSGraphicsLayer!
    var locator:AGSLocator!
    var calloutTemplate:AGSCalloutTemplate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMap()
    }
    
    func mapViewDidLoad(mapView: AGSMapView!) {
        locate()
    }
    func locate(){
        mapView.locationDisplay.autoPanMode = .Default
        mapView.locationDisplay.startDataSource()
    }
    
    func setupMap(){
        self.webMapId = "ea296ed0b68445e19e763f0d9c9823f0"
        self.webMap = AGSWebMap(itemId: self.webMapId, credential: nil)
        self.mapView.userInteractionEnabled = false
        self.webMap.delegate = self
        self.webMap.openIntoMapView(self.mapView)
        self.mapView.touchDelegate = self
        self.mapView.callout.delegate = self
        self.mapView.callout.accessoryButtonHidden = true
        self.locate()
    }
    
    func didOpenWebMap(webMap: AGSWebMap!, intoMapView mapView: AGSMapView!) {
        self.loadingMap.hidden = true
    }
    
    func callout(callout: AGSCallout!, willShowForFeature feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        callout.title = feature.attributeForKey("POI_NAME") as! String
        callout.detail = ""
        return true
    }
    
    func webMapDidLoad(webMap: AGSWebMap!) {
        self.mapView.userInteractionEnabled = true
    }
    
    //MARK: search bar delegate methods
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        if self.graphicLayer == nil {
            self.graphicLayer = AGSGraphicsLayer()
            self.mapView.addMapLayer(self.graphicLayer, withName:"Results")
            let pushpin = AGSPictureMarkerSymbol(imageNamed: "pin.png")
            pushpin.offset = CGPointMake(9, 16)
            pushpin.leaderPoint = CGPointMake(-9, 11)
            let renderer = AGSSimpleRenderer(symbol: pushpin)
            self.graphicLayer.renderer = renderer
        }
        else {
            self.graphicLayer.removeAllGraphics()
        }
        
        
        if self.locator == nil {
            let url = NSURL(string: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")
            self.locator = AGSLocator(URL: url)
            self.locator.delegate = self
        }
        let params = AGSLocatorFindParameters()
        params.text = searchBar.text
        params.outFields = ["*"]
        params.outSpatialReference = self.mapView.spatialReference
        params.location = AGSPoint(x: 0, y: 0, spatialReference: nil)
        self.locator.findWithParameters(params)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        var cancelButton: UIButton
        let topView: UIView = searchBar.subviews[0] as UIView
        for subView in topView.subviews {
            if subView.isKindOfClass(NSClassFromString("UINavigationButton")!) {
                cancelButton = subView as! UIButton
                cancelButton.setTitle("X", forState: UIControlState.Normal)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    //MARK: AGSLocator delegate methods
    
    func locator(locator: AGSLocator!, operation op: NSOperation!, didFind results: [AnyObject]!) {
        if results == nil || results.count == 0 {
            UIAlertView(title: "No hay resultados", message: "No se encontró ningún resultado.", delegate: nil, cancelButtonTitle: "OK").show()
        }
        else {
            if self.calloutTemplate == nil {
                self.calloutTemplate = AGSCalloutTemplate()
                self.calloutTemplate.titleTemplate = "${City}"
                self.calloutTemplate.detailTemplate = "${Match_addr}"
                self.graphicLayer.calloutDelegate = self.calloutTemplate
            }
            self.graphicLayer.addGraphic(results[0].graphic)
            
            //Zoom in to the results
            let extent = self.graphicLayer.fullEnvelope.mutableCopy() as! AGSMutableEnvelope
            extent.expandByFactor(1.5)
            self.mapView.zoomToEnvelope(extent, animated: true)
        }
    }
    
    func locator(locator: AGSLocator!, operation op: NSOperation!, didFailLocationsForAddress error: NSError!) {
        UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    @IBAction func parkLayerButton_Click(sender: UIButton) {
        if self.webMap.loaded{
            if (self.mapView.mapLayerForName(sender.restorationIdentifier) as AGSLayer).visible{
                (self.mapView.mapLayerForName(sender.restorationIdentifier) as AGSLayer).visible = false
                sender.setImage(UIImage(named: sender.restorationIdentifier! + "_Ap"), forState: .Normal)
            }else{
                (self.mapView.mapLayerForName(sender.restorationIdentifier) as AGSLayer).visible = true
                sender.setImage(UIImage(named: sender.restorationIdentifier!), forState: .Normal)
            }
        }
    }
    
}