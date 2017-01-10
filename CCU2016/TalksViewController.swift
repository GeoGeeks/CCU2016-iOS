//
//  TalksViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 30/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class TalksViewController: UIViewController {
    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet weak var sideMenuWidth: NSLayoutConstraint!
    
    @IBOutlet weak var day1Container: UIView!
    @IBOutlet weak var day3Container: UIView!
    
    var bottomMenu: BottomMenuViewController!
    
    var dayView:Day1TalksViewController!
    var sideMenuIsOpen:Bool!
    var selectedTalkId: String = ""
    
    @IBOutlet var daysButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSideMenu()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.day1Container.hidden = false
        self.day3Container.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.sideMenuWidth.constant = 0
        self.sideMenuIsOpen = false
        
        self.bottomMenu.talksButton.backgroundColor = UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1)
        self.bottomMenu.talksButton.setImage(UIImage(named: "5_charlas"), forState: .Normal)
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
    
    @IBAction func searchTalk(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("toSearchSegue", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bottomMenuSegue"{
            if let destinationVC = segue.destinationViewController as? BottomMenuViewController{
                self.bottomMenu = destinationVC
            }
        }
        if segue.identifier == "day1Segue"{
            if let destinationVC = segue.destinationViewController as? Day1TalksViewController{
                self.dayView = destinationVC
            }
        }
        if segue.identifier == "moreInfoSegue"{
            if let destinationVC = segue.destinationViewController as? TalkDetailViewController{
                destinationVC.talkId = self.selectedTalkId
            }
        }
    }
    
    @IBAction func day1Button_Click(sender: UIButton) {
        if self.dayView.selectedDay != 1{
            self.setSelectedDay(sender)
            self.day3Container.hidden = true
            self.day1Container.hidden = false
            self.dayView.selectedDay = 1
            self.dayView.populateTable()
        }
    }
    
    @IBAction func day2Button_Click(sender: UIButton) {
        if self.dayView.selectedDay != 2{
            self.setSelectedDay(sender)
            self.day3Container.hidden = true
            self.day1Container.hidden = false
            self.dayView.selectedDay = 2
            self.dayView.populateTable()
        }
    }
    @IBAction func day3Button_Click(sender: UIButton) {
        if day3Container.hidden == true{
            self.setSelectedDay(sender)
            self.day1Container.hidden = true
            self.day3Container.hidden = false
            self.dayView.selectedDay = 3
        }
    }
    @IBAction func day4Button_Click(sender: UIButton) {
        if self.dayView.selectedDay != 4{
            self.setSelectedDay(sender)
            self.day3Container.hidden = true
            self.day1Container.hidden = false
            self.dayView.selectedDay = 4
            self.dayView.populateTable()
        }
    }
    
    func setSelectedDay(sender: UIButton){
        for button in self.daysButtons{
            button.backgroundColor = UIColor(red: 208/255, green: 210/255, blue: 211/255, alpha: 1)
            button.tintColor = UIColor.blackColor()
        }
        sender.backgroundColor = UIColor(red: 41/255, green: 35/255, blue: 92/255, alpha: 1)
        sender.tintColor = UIColor.whiteColor()
    }
}
