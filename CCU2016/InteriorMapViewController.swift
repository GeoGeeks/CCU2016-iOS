//
//  InteriorMapViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 21/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class InteriorMapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSWebMapDelegate, AGSQueryTaskDelegate{
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var loadingMap: UIActivityIndicatorView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var daysButtons: [UIButton]!
    @IBOutlet weak var noTalksFoundLabel: UIView!
    @IBOutlet weak var basementButton: UIButton!
    @IBOutlet weak var level1Button: UIButton!
    
    var day1 = "20-09-2016"
    var day2 = "21-09-2016"
    var day3 = "22-09-2016"
    var day4 = "23-09-2016"
    
    var webMap:AGSWebMap!
    var webMapId:String!
    let basement = ["Planos Sotano", "Salones Sotano", "BaseSotano"]
    let level1 = ["Planos Nivel 1", "Salones Nivel 1"]
    
    var days: [Day]!
    var selectedDay: Int!
    var selectedRoomId = ""
    
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/serviciosCCU2016/MapServer/10")
    var queryTask: AGSQueryTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedDay = 1
        self.popupView.hidden = true
        self.webMapId = "97bacdba49ba40cda3ba0317794eb8c8"
        self.webMap = AGSWebMap(itemId: self.webMapId, credential: nil)
        self.webMap.delegate = self
        self.webMap.openIntoMapView(self.mapView)
        self.mapView.touchDelegate = self
        self.mapView.allowCallout = false

        self.days = []
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    @IBAction func closePopupButton_Click(sender: UIButton) {
        self.popupView.hidden = true
    }
    
    func didLoadLayer(layer: AGSLayer!) {
        if layer.name == "Planos Nivel 1"{
            mapView.zoomToEnvelope(layer.fullEnvelope , animated: true)
        }
    }
    
    func didOpenWebMap(webMap: AGSWebMap!, intoMapView mapView: AGSMapView!) {
        self.loadingMap.hidden = true
    }
    
    //Popup Config
    //-- Table
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.days.isEmpty{
            return 0
        }else{
            return self.days[self.selectedDay - 1].talks.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TalkCell", forIndexPath: indexPath) as! TalkTableViewCell
        cell.talkName.text = self.days[self.selectedDay - 1].talks[indexPath.row].title
        cell.talkTime.text = self.days[self.selectedDay - 1].talks[indexPath.row].timeBeg + "-" + self.days[self.selectedDay - 1].talks[indexPath.row].timeEnd
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let parent = self.parentViewController as! MapViewController
        parent.selectedTalkId = self.days[selectedDay - 1].talks[indexPath.row].talkId
        parent.performSegueWithIdentifier("moreInfoSegue", sender: nil)
    }
    
    func populateTable(){
        self.days = []
        for index in 1...4{
            let day = Day()
            day.name = "Día " + String(index)
            self.days.append(day)
        }
        self.queryTask = AGSQueryTask(URL: self.url)
        self.queryTask.delegate = self
        let query = AGSQuery()
        query.orderByFields = ["fecha_inicio ASC"]
        query.outFields = ["id_charla", "nombre_charla", "ID_SALA", "fecha_inicio", "fecha_fin"]
        query.returnGeometry = false
        query.whereClause = "nombre_charla <> 'Reunion de Ventas' AND id_sala ='" + self.selectedRoomId + "'"
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
            dateFormatter.dateFormat = "dd-MM-yyy"
            let talkhourI = hourFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI))
            let talkhourF = hourFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateF))
            let talk = TalkItem()
            talk.title = feature.attributeForKey("nombre_charla") as! String
            talk.talkId = String(feature.attributeForKey("id_charla") as! Int)
            talk.roomId = feature.attributeForKey("ID_SALA") as! String
            talk.timeBeg = talkhourI
            talk.timeEnd = talkhourF
            if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI)) == self.day1{
                if !days[0].talks.contains({$0.talkId == talk.talkId}) {
                    days[0].talks.append(talk)
                }
            }else if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI)) == self.day2{
                if !days[1].talks.contains({$0.talkId == talk.talkId}) {
                    days[1].talks.append(talk)
                }
            }else if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI)) == self.day3{
                if !days[2].talks.contains({$0.talkId == talk.talkId}) {
                    days[2].talks.append(talk)
                }
            }else if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI)) == self.day4{
                if !days[3].talks.contains({$0.talkId == talk.talkId}) {
                    days[3].talks.append(talk)
                }
            }
        }
        self.tableView.reloadData()
        if self.tableView.numberOfRowsInSection(0) < 1{
            self.noTalksFoundLabel.hidden = false
        }
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        UIAlertView(title: "Error", message: "No se encuentran resultados, intente más tarde", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func mapView(mapView: AGSMapView!, didClickAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [NSObject : AnyObject]!) {
        let geometryEngine = AGSGeometryEngine.defaultGeometryEngine()
        let buffer = geometryEngine.bufferGeometry(mappoint, byDistance:(10 * mapView.resolution))
        self.webMap.fetchPopupsForExtent(buffer.envelope)
    }
    
    func webMap(webMap: AGSWebMap!, didFetchPopups popups: [AnyObject]!, forExtent extent: AGSEnvelope!) {
        self.noTalksFoundLabel.hidden = true
        if popups.count > 0{
            let feature = popups[0].feature as AGSFeature
            if feature.attributeAsStringForKey("nombre_sala") != nil{
                self.popupTitle.text = "Salón: " + feature.attributeAsStringForKey("nombre_sala")
                self.selectedRoomId = feature.attributeAsStringForKey("ID_SALA")
                self.populateTable()
                self.popupView.hidden = false

            }
        }
    }
    
    //Botones Días---
    
    @IBAction func day1Button_Click(sender: UIButton) {
        if self.selectedDay != 1{
            self.setSelectedDay(sender)
            self.selectedDay = 1
            self.noTalksFoundLabel.hidden = true
            self.tableView.reloadData()
            if tableView.numberOfRowsInSection(0) < 1{
                self.noTalksFoundLabel.hidden = false
            }
        }
    }
    
    @IBAction func day2Button_Click(sender: UIButton) {
        if self.selectedDay != 2{
            self.setSelectedDay(sender)
            self.selectedDay = 2
            self.noTalksFoundLabel.hidden = true
            self.tableView.reloadData()
            if tableView.numberOfRowsInSection(0) < 1{
                self.noTalksFoundLabel.hidden = false
            }
        }
    }
    
    @IBAction func day3Button_Click(sender: UIButton) {
        if self.selectedDay != 3{
            self.setSelectedDay(sender)
            self.selectedDay = 3
            self.noTalksFoundLabel.hidden = true
            self.tableView.reloadData()
            if tableView.numberOfRowsInSection(0) < 1{
                self.noTalksFoundLabel.hidden = false
            }
        }
    }
    @IBAction func day4Button_Click(sender: UIButton) {
        if self.selectedDay != 4{
            self.setSelectedDay(sender)
            self.selectedDay = 4
            self.noTalksFoundLabel.hidden = true
            self.tableView.reloadData()
            if tableView.numberOfRowsInSection(0) < 1{
                self.noTalksFoundLabel.hidden = false
            }
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
    
    //Mostrar-ocultar capas---
    
    @IBAction func level1Button_Click(sender: UIButton) {
        if self.webMap.loaded{
            self.basementButton.setImage(UIImage(named: "mapa_int_1_apagado"), forState: .Normal)
            self.level1Button.setImage(UIImage(named: "mapa_int_2"), forState: .Normal)
            for layer in self.mapView.mapLayers as! [AGSLayer]{
                if self.level1.contains(layer.name){
                    layer.visible = true
                }else if self.basement.contains(layer.name){
                    layer.visible = false
                }
                if layer.name == "Planos Nivel 1"{
                    mapView.zoomToEnvelope(layer.fullEnvelope , animated: true)
                }
            }
        }
    }
    @IBAction func basementButton_Click(sender: UIButton) {
        if self.webMap.loaded{
            self.basementButton.setImage(UIImage(named: "mapa_int_1"), forState: .Normal)
            self.level1Button.setImage(UIImage(named: "mapa_int_2_apagado"), forState: .Normal)
            for layer in self.mapView.mapLayers as! [AGSLayer]{
                if self.basement.contains(layer.name){
                    layer.visible = true
                }else if self.level1.contains(layer.name){
                    layer.visible = false
                }
                if layer.name == "BaseSotano"{
                    mapView.zoomToEnvelope(layer.fullEnvelope , animated: true)
                }
            }
        }
    }
    //Config-----
    class Day{
        var name: String!
        var date: NSDate!
        var talks: [TalkItem] = []
    }
}
