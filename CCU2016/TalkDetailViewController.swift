//
//  TalkDetailViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 30/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class TalkDetailViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    AGSQueryTaskDelegate,
    AGSLayerDelegate,
    AGSFeatureLayerEditingDelegate {
    
    //Query Charla
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/serviciosCCU2016/MapServer/10")
    var queryTask: AGSQueryTask!
    
    //Query calificado 
    let urlRate = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/tablas_editables_CCU_2016/FeatureServer/2")
    var  rateQueryTask: AGSQueryTask!
    
    //Favoritos
    let urlFav = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/tablas_editables_CCU_2016/FeatureServer/1")
    var featureLayer :AGSFeatureLayer!
    var feature: AGSGraphic!
    var favQueryTask: AGSQueryTask!
    
    var isUser:Bool = false
    var isFavorite: Bool = false
    var talkId = ""
    var userId = ""
    var favoriteIds:[Int]!
    var type: Int!
    
    var SpeakersArray:[SpeakerItem]!
    
    @IBOutlet weak var talkTitle: UILabel!
    @IBOutlet weak var talkTime: UILabel!
    @IBOutlet weak var talkDesc: UILabel!
    @IBOutlet weak var talkRoom: UILabel!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var asistButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    
    var intId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateTalk()
        
        self.rateButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.asistButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.favButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadingView.hidden = false
        self.isUserFunc()
        if self.isUser{
            self.talkRated()
            self.setUpFavorites()
            self.talkInFav()
        }else{
            self.loadingView.hidden = true
        }
    }
    
    func populateTalk(){
        self.SpeakersArray = []
        self.tableView.delegate = self
        self.tableView.dataSource = self        
        self.queryTask = AGSQueryTask(URL: self.url)
        self.queryTask.delegate = self
        let query = AGSQuery()
        query.whereClause = "salageneral = 1 AND id_charla = " + self.talkId
        query.outFields = ["id_charla", "nombre_charla", "fecha_inicio", "fecha_fin" ,"nombre_sala", "descripcion", "expositores"]
        query.returnGeometry = false
        self.queryTask.executeWithQuery(query)
    }
    
    func talkRated(){
        self.rateQueryTask = AGSQueryTask(URL: self.urlRate)
        self.rateQueryTask.delegate = self
        let query = AGSQuery()
        query.outFields = []
        query.whereClause = "id_charla = " + self.talkId + "AND correo_usuario = '" + self.userId + "'"
        query.returnGeometry = false
        self.rateQueryTask.executeWithQuery(query)
    }
    
    func talkInFav(){
        self.favoriteIds = []
        self.favQueryTask = AGSQueryTask(URL: urlFav)
        self.favQueryTask.delegate = self
        let query = AGSQuery()
        query.outFields = ["tipo", "id_favorito"]
        query.whereClause = "id_charla = " + self.talkId + "AND correo_usuario = '" + self.userId + "'"
        query.returnGeometry = false
        self.favQueryTask.executeWithQuery(query)
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        if queryTask.URL == self.url {
            let feature = featureSet.features[0]
            self.talkTitle.text = feature.attributeForKey("nombre_charla") as? String
            
            let dateI = (feature.attributeForKey("fecha_inicio") as! Double) / 1000
            let dateF = (feature.attributeForKey("fecha_fin") as! Double) / 1000
            let hourFormatter = NSDateFormatter()
            hourFormatter.dateFormat = "h:mm a"
            hourFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            let talkhourI = hourFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateI))
            let talkhourF = hourFormatter.stringFromDate(NSDate(timeIntervalSince1970: dateF))
            self.talkTime.text = talkhourI + "-" + talkhourF
            //Descripción Charla! ------
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.Justified
            
            let attributedString = NSAttributedString(string: (feature.attributeForKey("descripcion") as? String)!, attributes: [
                    NSParagraphStyleAttributeName: paragraphStyle,
                    NSBaselineOffsetAttributeName: NSNumber(float: 0)
                ])
            self.talkDesc.attributedText = attributedString
            //Salón
            self.talkRoom.text = feature.attributeForKey("nombre_sala") as? String
            //Expositores
            let speakers = String(feature.attributeForKey("expositores")).stringByReplacingOccurrencesOfString("&amp;", withString: "&")
            for spk in speakers.componentsSeparatedByString(";"){
                let spkItem = SpeakerItem()
                spkItem.name = spk.componentsSeparatedByString("#")[0]
                spkItem.company = spk.componentsSeparatedByString("#")[1]
                spkItem.contact = spk.componentsSeparatedByString("#")[2]
                self.SpeakersArray.append(spkItem)
            }
            self.tableHeight.constant = CGFloat(self.SpeakersArray.count) * 65
            self.tableView.reloadData()
        }else if queryTask.URL == self.urlRate{
            if featureSet.features.count > 0{
                self.rateButton.enabled = false
                self.rateButton.setImage(UIImage(named: "charlas_calificar_seleccionado"), forState: .Normal)
            }
        }else if queryTask.URL == self.urlFav{
            self.loadingView.hidden = true
            if featureSet.features.count > 0{
                for feat in featureSet.features{
                    if feat.attributeForKey("tipo") as! Int == 1{
                        self.disableFavButton()
                        self.favoriteIds.append(feat.attributeForKey("id_favorito") as! Int)
                    }else{
                        self.disableAsistButton()
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.SpeakersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SpeakerCell") as! SpeakerTableViewCell
        cell.name.text = self.SpeakersArray[indexPath.row].name
        cell.company.text = self.SpeakersArray[indexPath.row].company
        cell.contact.text = self.SpeakersArray[indexPath.row].contact
        return cell
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        self.loadingView.hidden = true
    }
    //Calificar---
    @IBAction func rateTalkButton_Click(sender: UIButton) {
        if self.isUser {
            performSegueWithIdentifier("rateTalkSegue", sender: nil)
        }else{
           self.noRegisteredUser()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "rateTalkSegue"{
            if let destinationVC = segue.destinationViewController as? RateTalkViewController{
                destinationVC.talkId = self.talkId
                destinationVC.userId = self.userId
                destinationVC.talkTitle = self.talkTitle.text!
            }
        }
    }
    
    //Favoritos ---
    
    @IBAction func favoritesButton_Click(sender: UIButton) {
        if self.isUser{
            self.type = 1
            self.addFavorite()
        }else{
            self.noRegisteredUser()
        }
    }
    
    func setUpFavorites(){
        self.featureLayer = AGSFeatureLayer(URL: self.urlFav, mode: .OnDemand)
        self.featureLayer.delegate = self
        self.featureLayer.editingDelegate = self
    }
    
    func addFavorite(){
        self.view.userInteractionEnabled = false
        self.intId = Int(self.talkId)!
        let attrs: [NSObject : AnyObject] = [
            "correo_usuario": self.userId,
            "tipo": self.type,
            "id_charla": intId
        ]
        self.feature.setAttributes(attrs)
        if self.feature != nil{
            if !self.isFavorite || self.type == 0{
                self.featureLayer.applyEditsWithFeaturesToAdd([feature], toUpdate: nil, toDelete: nil)
            }else{
                self.featureLayer.applyEditsWithFeaturesToAdd(nil, toUpdate: nil, toDelete: self.favoriteIds)
            }
        }
    }
    
    func layerDidLoad(layer: AGSLayer!) {
        self.feature = self.featureLayer.featureWithTemplate(self.featureLayer.templates[0] as! AGSFeatureTemplate)
    }
    
    func featureLayer(featureLayer: AGSFeatureLayer!, operation op: NSOperation!, didFailFeatureEditsWithError error: NSError!) {
        self.view.userInteractionEnabled = true
        let alert = UIAlertController(title: "Error de conexión", message: "No podemos conectar con el servidor. Por favor verifique su conexión a internet y vuela a intentar.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func featureLayer(featureLayer: AGSFeatureLayer!, operation op: NSOperation!, didFeatureEditsWithResults editResults: AGSFeatureLayerEditResults!) {
        self.view.userInteractionEnabled = true
        if editResults.addResults != nil{
            var msg = ""
            var ttl = ""
            if self.type == 1{
                let er = editResults.addResults[0] as! AGSEditResult
                self.favoriteIds.append(er.objectId)
                ttl = "Charla Guardada"
                msg = "La charla se ha agregado a su agenda."
                self.disableFavButton()
            }else{
                ttl = "Asistencia Confirmada"
                msg = "Gracias por asistir a la charla."
                self.disableAsistButton()
            }
            
            let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        if editResults.deleteResults != nil{
            self.favButton.setImage(UIImage(named: "charlas_favoritos"), forState: .Normal)
            self.isFavorite = false
        }
    }
    
    func disableFavButton(){
        self.isFavorite = true
        self.favButton.setImage(UIImage(named: "charlas_favoritos_seleccionado"), forState: .Normal)
        
    }
    
    func disableAsistButton(){
        self.asistButton.enabled = false
        self.asistButton.setImage(UIImage(named: "charlas_asisti_seleccionado"), forState: .Normal)
    }
    
    //Asistencia ---
    
    @IBAction func asistButton_Click(sender: UIButton) {
        if self.isUser{
            self.type = 0
            self.addFavorite()
        }else{
            self.noRegisteredUser()
        }
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
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
