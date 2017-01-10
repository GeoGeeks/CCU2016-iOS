//
//  MapViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 30/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class MapViewController: UIViewController {

    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet weak var sideMenuWidth: NSLayoutConstraint!
    
    @IBOutlet weak var interiorMapContainer: UIView!
    @IBOutlet weak var exteriorMapContainer: UIView!
    @IBOutlet weak var interiorMapButton: UIButton!
    @IBOutlet weak var exteriorMapButton: UIButton!
    
    var bottomMenu: BottomMenuViewController!
    
    var sideMenuIsOpen:Bool!
    var selectedTalkId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clientID = "F6fs431UpgVRHluc"
        do{
            try AGSRuntimeEnvironment.setClientID(clientID)
        }catch let error {
            print("Error using client ID : \(error)")
        }
        
        self.interiorMapButton.backgroundColor = UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1)
        self.interiorMapButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.exteriorMapButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        self.exteriorMapButton.setTitleColor(UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1), forState: .Normal)
        self.setUpSideMenu()
        self.exteriorMapContainer.hidden = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.sideMenuWidth.constant = 0
        self.sideMenuIsOpen = false
        
        self.bottomMenu.mapButton.backgroundColor = UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1)
        self.bottomMenu.mapButton.setImage(UIImage(named: "6_mapa"), forState: .Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //SideMenu-----
    func setUpSideMenu(){
        let menuSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.hideMenu))
        menuSwipe.direction = .Left
        view.addGestureRecognizer(menuSwipe)
    }
    
    func hideMenu(sender: UIGestureRecognizer){
        if self.sideMenuIsOpen == true{
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.sideMenuWidth.constant -= 200
                self.view.layoutIfNeeded()
                }, completion: nil)
            self.sideMenuIsOpen = false
        }
    }
    
    @IBAction func sideBarButton_Click(sender: UIBarButtonItem) {
        self.toggleSideMenu()
    }
    
    func toggleSideMenu(){
        if self.sideMenuIsOpen != true {
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.sideMenuWidth.constant += 200
                self.view.layoutIfNeeded()
                }, completion: nil)
            self.sideMenuIsOpen = true
        }else{
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.sideMenuWidth.constant -= 200
                self.view.layoutIfNeeded()
                }, completion: nil)
            self.sideMenuIsOpen = false
        }
    }

    @IBAction func interiorMapButton_Click(sender: UIButton) {
        if self.interiorMapContainer.hidden == true{
            self.interiorMapButton.backgroundColor = UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1)
            self.interiorMapButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.exteriorMapButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            self.exteriorMapButton.setTitleColor(UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1), forState: .Normal)
            self.interiorMapContainer.hidden = false
            self.exteriorMapContainer.hidden = true
        }
    }
    @IBAction func exteriorMapButton_Click(sender: AnyObject) {
        if self.exteriorMapContainer.hidden == true{
            self.exteriorMapButton.backgroundColor = UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1)
            self.exteriorMapButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.interiorMapButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            self.interiorMapButton.setTitleColor(UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1), forState: .Normal)
            self.interiorMapContainer.hidden = true
            self.exteriorMapContainer.hidden = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bottomMenuSegue"{
            if let destinationVC = segue.destinationViewController as? BottomMenuViewController{
                self.bottomMenu = destinationVC
            }
        }
        if segue.identifier == "moreInfoSegue"{
            if let destinationVC = segue.destinationViewController as? TalkDetailViewController{
                destinationVC.talkId = self.selectedTalkId
            }
        }
    }
}
