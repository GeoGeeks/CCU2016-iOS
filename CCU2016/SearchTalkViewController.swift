//
//  SearchTalkViewController.swift
//  CCU2016
//
//  Created by Semillero Esri Colombia SAS on 18/08/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class SearchTalkViewController:
UIViewController,
UISearchBarDelegate,
UITableViewDataSource,
UITableViewDelegate,
AGSQueryTaskDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var queryTask: AGSQueryTask!
    var query: AGSQuery!
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/serviciosCCU2016/MapServer/10")
    var talks:[TalkItem]!
    
    var selectedTalkId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.setupTable()
        self.setUpQueryTask()
    }
    
    //Tabla ---
    func setupTable(){
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.talks = []
    }
    
    func setUpQueryTask(){
        self.queryTask = AGSQueryTask(URL: self.url)
        self.queryTask.delegate = self
        self.query = AGSQuery()
        self.query.orderByFields = ["fecha_inicio ASC"]
        self.query.outFields = ["id_charla", "nombre_charla", "fecha_inicio", "fecha_fin" ,"nombre_sala"]
        self.query.returnGeometry = false
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.talks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Day1TableViewCell", forIndexPath: indexPath) as! Day1TableViewCell
        cell.title.text = self.talks[indexPath.row].title
        cell.time.text = self.talks[indexPath.row].timeBeg + "-" + self.talks[indexPath.row].timeEnd
        cell.room.text = self.talks[indexPath.row].room
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedTalkId = talks[indexPath.row].talkId
        self.performSegueWithIdentifier("moreInfoSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moreInfoSegue"{
            if let destinationVC = segue.destinationViewController as? TalkDetailViewController{
                destinationVC.talkId = self.selectedTalkId
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        self.talks = []
        self.tableView.reloadData()
        self.query.whereClause = "nombre_charla LIKE '%" + searchBar.text! + "%' AND salageneral = 1"
        self.queryTask.executeWithQuery(query)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        var cancelButton: UIButton
        let topView: UIView = searchBar.subviews[0] as UIView
        for subView in topView.subviews {
            if subView.isKindOfClass(NSClassFromString("UINavigationButton")!) {
                cancelButton = subView as! UIButton
                cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                cancelButton.setTitle("X", forState: UIControlState.Normal)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        if featureSet.features.count < 1{
            let alert = UIAlertController(title: "No hay resultados", message: "Por favor intente otra búsqueda", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
        self.tableView.reloadData()
    }
}
