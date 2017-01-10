//
//  Day3TalksViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 13/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class Day3TalksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AGSQueryTaskDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/serviciosCCU2016/MapServer/10")
    var queryTask: AGSQueryTask!
    
    var rooms: [RoomItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.rooms = []
        self.populateTable()
    }
    
    //Tabla
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rooms.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms[section].talks.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let header = tableView.dequeueReusableCellWithIdentifier("TalkHeaderCell", forIndexPath: indexPath) as! TalkHeaderCell
            header.hlabel?.text = rooms[indexPath.section].name
            return header
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("TalkCell", forIndexPath: indexPath) as! TalkTableViewCell
            let section = indexPath.section
            let row = indexPath.row - 1
            let talk = rooms[section].talks[row]
            
            cell.talkName.text = talk.title
            cell.talkTime.text = talk.timeBeg + " - " + talk.timeEnd
            
            return cell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.rooms[indexPath.section].collapsed == true && indexPath.row != 0{
            return 0
        }else if indexPath.row == 0{
            return 45
        }else{
            return 60
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0{
            let parent = self.parentViewController as! TalksViewController
            parent.selectedTalkId = rooms[indexPath.section].talks[indexPath.row - 1].talkId
            parent.performSegueWithIdentifier("moreInfoSegue", sender: nil)
        }else if indexPath.row == 0{
            self.rooms[indexPath.section].collapsed = !self.rooms[indexPath.section].collapsed
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TalkHeaderCell
            if self.rooms[indexPath.section].collapsed == false{
                cell.himage?.image = UIImage(named: "boton_cerrar")
            }else{
                cell.himage?.image = UIImage(named: "boton_abrir")
            }
        }
    }
    
    func populateTable(){
        self.queryTask = AGSQueryTask(URL: self.url)
        self.queryTask.delegate = self
        let query = AGSQuery()
        query.whereClause = "fecha_inicio > DATE '2016/09/22' AND fecha_inicio < DATE '2016/09/23' AND salageneral = 1"
        query.orderByFields = ["fecha_inicio ASC"]
        query.outFields = ["id_charla", "nombre_charla", "nombre_sala", "sector", "fecha_inicio", "fecha_fin"]
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
            let headerText = feature.attributeForKey("nombre_sala") as! String + " - " + (feature.attributeForKey("sector") as! String)
            if rooms.contains({$0.name == headerText}){
                self.rooms.filter{$0.name == headerText}.first?.talks.append(talk)
            }else{
                let room = RoomItem()
                room.name = headerText
                room.collapsed = true
                room.talks.append(talk)
                self.rooms.append(room)
            }
            
        }
        self.rooms.sortInPlace({$0.name < $1.name})
        self.tableView.reloadData()
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        UIAlertView(title: "Error", message: "No se encuentran resultados, intente más tarde", delegate: nil, cancelButtonTitle: "OK").show()
    }


}
