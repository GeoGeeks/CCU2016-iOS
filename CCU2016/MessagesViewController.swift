//
//  MessagesViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 29/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class MessagesViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, AGSQueryTaskDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadMsg: UIView!
    
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/serviciosCCU2016/MapServer/9")
    var queryTask:AGSQueryTask!
    
    var messages:[MessageItem]!
    var selectedMessage: MessageItem!
    var cadena = ""
    var datosCont = ""
    
    var myStrings:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadMsg.hidden = false
        
        self.myStrings = []
        self.leerDatos()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.messages = []
        
        // Do any additional setup after loading the view.
        self.tableView.separatorColor = UIColor(red: 181/255, green: 181/255, blue: 180/255, alpha: 1)
        
        //QueryTask Para comprobar la consulta a la BD @JoseGarcia
        queryTask = AGSQueryTask(URL: url)
        queryTask.delegate = self
        
        let query = AGSQuery()
        query.whereClause = "1=1"
        query.outFields = ["titulo", "mensaje", "fecha_doc", "id_msn"]
        queryTask.executeWithQuery(query)
    }
    
    //Resultado del QueryTask @JoseGarcia
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        //get feature, and load in to table
        self.populateTable(featureSet)
    }
    //Error QueryTask @JoseGarcia
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        self.loadMsg.hidden = true
        UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Nvigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messageMoreInfo"{
            if let destinationVC = segue.destinationViewController as? MessageViewController{
                destinationVC.moreInfoId = selectedMessage
            }
        }
    }
    
    //Table
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageTableViewCell
        cell.title.text = self.messages[indexPath.row].title
        cell.date.text = self.messages[indexPath.row].date
        
        if myStrings.contains(self.messages[indexPath.row].messageId){
            //            poner estilo no leido
            cell.identificadorCirculo.image = UIImage(named: "circulo_apagado")
            cell.indicadorFlecha.image = UIImage(named: "mensajes-flecha")
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedMessage = self.messages[indexPath.row]
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! MessageTableViewCell
        cell.identificadorCirculo.image = UIImage(named: "circulo_apagado")
        cell.indicadorFlecha.image = UIImage(named: "mensajes-flecha")
        
        if !myStrings.contains(self.messages[indexPath.row].messageId){
            myStrings.append(self.messages[indexPath.row].messageId)
            
            var ids = ""
            for id in myStrings{
                if id != ""{
                    ids += id + ","
                }
            }
            let dir = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create:true)
            let file = dir.URLByAppendingPathComponent("msnLeidos.txt")
            
            do{
                try ids.writeToURL(file, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                UIAlertView(title: "Error", message: "Se ha presentado un error. Intente más tarde.", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        }
        
        self.selectedMessage = self.messages[indexPath.row]
        performSegueWithIdentifier("messageMoreInfo", sender: nil)
    }
    
    func leerDatos(){
        let directorio = NSFileManager.defaultManager()
        do{
            let fileurl = try directorio.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            let file = fileurl.URLByAppendingPathComponent("msnLeidos.txt")
            if directorio.fileExistsAtPath(file.path!){
                let datosCont = try String(contentsOfURL: file, encoding: NSUTF8StringEncoding)
                myStrings = datosCont.componentsSeparatedByString(",")
            }
        }
        catch{
            UIAlertView(title: "Error", message: "Se ha presentado un error. Intente más tarde.", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    func populateTable(featureSet: AGSFeatureSet){
        if featureSet.features.count > 0{
            for index in 1...featureSet.features.count{
                let message = MessageItem()
                message.messageId = String(featureSet.features[index - 1].attributeForKey("id_msn") as! Int)
                let date = (featureSet.features[index - 1].attributeForKey("fecha_doc") as! Double) / 1000
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "M/d/yyyy"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                let strDate = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: date))
                //message.messageId = featureSet.features[index - 1].attributeForKey("titulo") as! String
                message.title = featureSet.features[index - 1].attributeForKey("titulo") as! String
                message.detail = featureSet.features[index - 1].attributeForKey("mensaje") as! String
                message.date = strDate
                self.messages.append(message)
            }
        }
        self.loadMsg.hidden = true
        self.tableView.reloadData()
    }
}