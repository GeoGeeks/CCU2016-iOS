//
//  Day1TalksViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 13/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class Day1TalksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AGSQueryTaskDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noTalksFoundLable: UIView!
    
    var selectedDay: Int = 1
    
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/serviciosCCU2016/MapServer/10")
    var queryTask: AGSQueryTask!
    
    var talks:[TalkItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noTalksFoundLable.hidden = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.populateTable()
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let parent = self.parentViewController as! TalksViewController
        parent.selectedTalkId = talks[indexPath.row].talkId
        parent.performSegueWithIdentifier("moreInfoSegue", sender: nil)
    }
    
    func populateTable(){
        self.talks = []
        self.queryTask = AGSQueryTask(URL: self.url)
        self.queryTask.delegate = self
        let query = AGSQuery()
        query.orderByFields = ["fecha_inicio ASC"]
        query.outFields = ["id_charla", "nombre_charla", "fecha_inicio", "fecha_fin" ,"nombre_sala"]
        query.returnGeometry = false
        switch selectedDay {
        case 1:
            query.whereClause = "fecha_inicio < DATE '2016/09/21' AND salageneral = 1 AND nombre_charla <> 'Reunion de Ventas'"
            break
        case 2:
            query.whereClause = "fecha_inicio > DATE '2016/09/21' AND fecha_inicio < DATE '2016/09/22' AND salageneral = 1"
            break
        case 4:
            query.whereClause = "fecha_inicio > DATE '2016/09/23' AND fecha_inicio < DATE '2016/09/24' AND salageneral = 1"
            break
        default:
            break
        }
        self.noTalksFoundLable.hidden = false
        self.queryTask.executeWithQuery(query)
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        for feature in featureSet.features{
            let dateI = (feature.attributeForKey("fecha_inicio") as! Double) / 1000
            let dateF = (feature.attributeForKey("fecha_fin") as! Double) / 1000
            let hourFormatter = NSDateFormatter()
            hourFormatter.dateFormat = "H:mm"
            hourFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
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
        self.noTalksFoundLable.hidden = true
        self.tableView.reloadData()
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        self.noTalksFoundLable.hidden = true
        UIAlertView(title: "Error", message: "No se encuentran resultados, intente más tarde", delegate: nil, cancelButtonTitle: "OK").show()
    }

}
