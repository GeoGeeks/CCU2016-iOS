//
//  FavoritesViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 30/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AGSQueryTaskDelegate {
    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet weak var sideMenuWidth: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var sideMenuIsOpen:Bool!
    var bottomMenu: BottomMenuViewController!
    var days: [Day]!
    var moreInfoId: String!
    
    var favoriteIds: [Int]!
    let urlFav = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/tablas_editables_CCU_2016/FeatureServer/1")
    var favQueryTask: AGSQueryTask!
    
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/serviciosCCU2016/MapServer/10")
    var queryTask: AGSQueryTask!
    
    var isUser: Bool!
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSideMenu()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.sideMenuWidth.constant = 0
        self.sideMenuIsOpen = false
        self.bottomMenu.favButton.backgroundColor = UIColor(red: 53/255, green: 27/255, blue: 112/255, alpha: 1)
        self.bottomMenu.favButton.setImage(UIImage(named: "8_favoritos"), forState: .Normal)
        self.days = []
        self.isUserFunc()
        if !self.isUser{
            self.noRegisteredUser()
        }else{
            tableView.reloadData()
            self.populateTable()
        }
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.days[section].talks.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let header = tableView.dequeueReusableCellWithIdentifier("TalkHeaderCell", forIndexPath: indexPath) as! TalkHeaderCell
            header.hlabel?.text = days[indexPath.section].name
            header.himage?.image = UIImage(named: "boton_abrir")
            return header
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("Day1TableViewCell", forIndexPath: indexPath) as! Day1TableViewCell
            let section = indexPath.section
            let row = indexPath.row - 1
            let talk = days[section].talks[row]
            
            cell.title.text = talk.title
            cell.time.text = talk.timeBeg + " - " + talk.timeEnd
            cell.room.text = talk.room
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.days[indexPath.section].collapsed == true && indexPath.row != 0{
            return 0
        }else if indexPath.row == 0{
            return 45
        }else{
            return 60
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0{
            //let parent = self.parentViewController as! TalksViewController
            self.moreInfoId = days[indexPath.section].talks[indexPath.row - 1].talkId
            performSegueWithIdentifier("moreInfoSegue", sender: nil)
        }else{
            self.days[indexPath.section].collapsed = !self.days[indexPath.section].collapsed
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TalkHeaderCell
            if self.days[indexPath.section].collapsed == false{
                cell.himage?.image = UIImage(named: "boton_cerrar")
            }else{
                cell.himage?.image = UIImage(named: "boton_abrir")
            }
        }
    }
    
    func populateTable(){
        self.favoriteIds = []
        self.favQueryTask = AGSQueryTask(URL: self.urlFav)
        self.favQueryTask.delegate = self
        let query = AGSQuery()
        query.outFields = ["id_charla"]
        query.whereClause = "correo_usuario = '" + self.userId + "' AND tipo = 1"
        query.returnGeometry = false
        self.favQueryTask.executeWithQuery(query)
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        if queryTask.URL == self.url {
            for feature in featureSet.features{
                let dateI = (feature.attributeForKey("fecha_inicio") as! Double) / 1000
                let dateF = (feature.attributeForKey("fecha_fin") as! Double) / 1000
                let hourFormatter = NSDateFormatter()
                hourFormatter.dateFormat = "H:mm"
                hourFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                let dateFormatter = NSDateFormatter()
                //dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                dateFormatter.dateFormat = "M/d/yy"
                let talkhourI = hourFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI))
                let talkhourF = hourFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateF))
                let talk = TalkItem()
                talk.title = feature.attributeForKey("nombre_charla") as! String
                talk.talkId = String(feature.attributeForKey("id_charla") as! Int)
                talk.timeBeg = talkhourI
                talk.timeEnd = talkhourF
                talk.room = feature.attributeForKey("nombre_sala") as! String
                //Día 1 ---
                if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI)) == "9/20/16"{
                    if !days.contains({$0.name == "Septiembre 20"}){
                        let day1 = Day()
                        day1.name = "Septiembre 20"
                        day1.collapsed = true
                        self.days.append(day1)
                    }
                    let index = self.days.indexOf({$0.name == "Septiembre 20"})
                    if !days[index!].talks.contains({$0.talkId == talk.talkId}){
                        self.days[index!].talks.append(talk)
                    }
                }
                //Día 2 ---
                if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI)) == "9/21/16"{
                    if !days.contains({$0.name == "Septiembre 21"}){
                        let day1 = Day()
                        day1.name = "Septiembre 21"
                        day1.collapsed = true
                        self.days.append(day1)
                    }
                    let index = self.days.indexOf({$0.name == "Septiembre 21"})
                    if !days[index!].talks.contains({$0.talkId == talk.talkId}){
                        self.days[index!].talks.append(talk)
                    }
                }
                //Día 3 ---
                if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI)) == "9/22/16"{
                    if !days.contains({$0.name == "Septiembre 22"}){
                        let day1 = Day()
                        day1.name = "Septiembre 22"
                        day1.collapsed = true
                        self.days.append(day1)
                    }
                    let index = self.days.indexOf({$0.name == "Septiembre 22"})
                    if !days[index!].talks.contains({$0.talkId == talk.talkId}){
                        self.days[index!].talks.append(talk)
                    }
                }
                //Día 4 ---
                if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI)) == "9/23/16"{
                    if !days.contains({$0.name == "Septiembre 23"}){
                        let day1 = Day()
                        day1.name = "Septiembre 23"
                        day1.collapsed = true
                        self.days.append(day1)
                    }
                    let index = self.days.indexOf({$0.name == "Septiembre 23"})
                    if !days[index!].talks.contains({$0.talkId == talk.talkId}){
                        self.days[index!].talks.append(talk)
                    }
                }
                
            }
            self.tableView.reloadData()
        }else if queryTask.URL == self.urlFav{
            if featureSet.features.count > 0{
                for feat in featureSet.features{
                    self.favoriteIds.append(feat.attributeForKey("id_charla") as! Int)
                }
                self.queryTalks()
            }
        }
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        let alert = UIAlertController(title: "Error de conexión", message: "No podemos conectar con el servidor. Por favor verifique su conexión a internet y vuela a intentar.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func queryTalks(){
        self.queryTask = AGSQueryTask(URL: self.url)
        self.queryTask.delegate = self
        let query = AGSQuery()
        query.orderByFields = ["fecha_inicio ASC"]
        query.outFields = ["id_charla", "nombre_charla", "fecha_inicio", "fecha_fin" ,"nombre_sala"]
        query.returnGeometry = false
        var theWhere = "id_charla IN " + String(self.favoriteIds)
        theWhere = theWhere.stringByReplacingOccurrencesOfString("[", withString: "(")
        theWhere = theWhere.stringByReplacingOccurrencesOfString("]", withString: ")")
        query.whereClause = theWhere
        self.queryTask.executeWithQuery(query)
    }
    
    //Verificar Usuario---
    
    func isUserFunc() {
        let directorio = NSFileManager.defaultManager()
        do{
            let fileurl = try directorio.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            let file = fileurl.URLByAppendingPathComponent("datosUsuario.txt")
            if directorio.fileExistsAtPath(file.path!){
                self.isUser = true
                let datosCont = try String(contentsOfURL: file, encoding: NSUTF8StringEncoding)
                let myStrings = datosCont.componentsSeparatedByString(",")
                self.userId = myStrings[2]
            }else{
                self.isUser = false
            }
        }
        catch{
            self.isUser = false
            let alert = UIAlertController(title: "Error de Lectura", message: "Por favor intente más tarde.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func noRegisteredUser(){
        let alert = UIAlertController(title: "Es necesario registrarse", message: "Por favor realice el proceso de registro para acceder a esta funcionalidad.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Registrarme", style: UIAlertActionStyle.Default, handler: {action in self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("AccountViewController"), animated: true)}))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default, handler: {action in self.navigationController?.popViewControllerAnimated(true)}))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Configuración adicional ---
    
    class Day{
        var name: String!
        var collapsed: Bool!
        var talks: [TalkItem] = []
    }

}
