//
//  PlanetEsriViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 30/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class PlanetEsriViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AGSQueryTaskDelegate {
    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet weak var sideMenuWidth: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingFav: UIView!
    
    var sideMenuIsOpen:Bool!
    var bottomMenu: BottomMenuViewController!
    
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/serviciosCCU2016/MapServer/10")
    var queryTask: AGSQueryTask!
    
    var talks: [TalkItem]!
    var moreInfoId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSideMenu()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.talks = []
        self.loadingFav.hidden = false
        self.populateTable()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.sideMenuWidth.constant = 0
        self.sideMenuIsOpen = false
        
        self.bottomMenu.planetButton.backgroundColor = UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1)
        self.bottomMenu.planetButton.setImage(UIImage(named: "7_planetaesri"), forState: .Normal)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bottomMenuSegue"{
            if let destinationVC = segue.destinationViewController as? BottomMenuViewController{
                self.bottomMenu = destinationVC
            }
        }
        if segue.identifier == "moreInfoSegue"{
            if let destinationVC = segue.destinationViewController as? TalkDetailViewController{
                destinationVC.talkId = moreInfoId
            }
        }
    }
    
    //Table
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.talks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TalkCell", forIndexPath: indexPath) as! TalkTableViewCell
        let row = indexPath.row
        let talk = talks[row]
        
        cell.talkName.text = talk.title
        cell.talkTime.text = talk.timeBeg + " - " + talk.timeEnd
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.moreInfoId = self.talks[indexPath.row].talkId
        performSegueWithIdentifier("moreInfoSegue", sender: nil)
    }

    func populateTable(){
        self.queryTask = AGSQueryTask(URL: self.url)
        self.queryTask.delegate = self
        let query = AGSQuery()
        query.whereClause = "fecha_inicio > DATE '2016/09/22' AND fecha_inicio < DATE '2016/09/23' AND salageneral = 1 AND nombre_sala = 'Sol 1'"
        query.orderByFields = ["fecha_inicio ASC"]
        query.outFields = ["id_charla", "nombre_charla", "fecha_inicio", "fecha_fin" ,"nombre_sala"]
        query.returnGeometry = false
        self.queryTask.executeWithQuery(query)
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        for feature in featureSet.features{
            let dateI = (feature.attributeForKey("fecha_inicio") as! Double) / 1000
            let dateF = (feature.attributeForKey("fecha_fin") as! Double) / 1000
            let hourFormatter = NSDateFormatter()
            hourFormatter.dateFormat = "H:mm"
            hourFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            let talkhourI = hourFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI))
            let talkhourF = hourFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateF))
            let talk = TalkItem()
            talk.title = feature.attributeForKey("nombre_charla") as! String
            talk.talkId = String(feature.attributeForKey("id_charla") as! Int)
            talk.timeBeg = talkhourI
            talk.timeEnd = talkhourF
            talk.room = feature.attributeForKey("nombre_sala") as! String
            if !talks.contains({$0.talkId == talk.talkId}) {
                talks.append(talk)
            }
        }
        self.loadingFav.hidden = true
        self.tableView.reloadData()
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        self.loadingFav.hidden = true
        UIAlertView(title: "Error", message: "No se encuentran resultados, intente más tarde", delegate: nil, cancelButtonTitle: "OK").show()
    }


}
