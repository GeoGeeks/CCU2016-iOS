//
//  RateTalkViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 6/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class RateTalkViewController: UIViewController, UITextViewDelegate, AGSLayerDelegate, AGSFeatureLayerEditingDelegate {
    
    @IBOutlet var stars: [UIButton]!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var comentTextView: UITextView!
    @IBOutlet weak var talkTitleLable: UILabel!
    
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/tablas_editables_CCU_2016/FeatureServer/2")
    var featureLayer :AGSFeatureLayer!
    var feature: AGSGraphic!
    
    var talkId = ""
    var talkTitle = ""
    var userId = ""
    var coment = ""
    
    var rate: Int = 3
    let talkTextPlaceholder = "En este espacio puede escribir su opinión acerca de la conferencia."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpGDB()
        self.talkTitleLable.text = self.talkTitle
        self.sendButton.alpha = 0.5
        self.sendButton.enabled = false
        self.setupComentTextView()
    }
    
    func setupComentTextView(){
        self.comentTextView.text = self.talkTextPlaceholder
        self.comentTextView.textColor = UIColor.lightGrayColor()
        self.comentTextView.delegate = self
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.talkTextPlaceholder
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func starTapped(sender: UIButton) {
        self.rate = self.stars.indexOf(sender)! + 1
        for index in 0...4{
            if index <= self.stars.indexOf(sender){
                self.stars[index].setImage(UIImage(named: "estrella"), forState: .Normal)
            }else{
                self.stars[index].setImage(UIImage(named: "estrella_apagada"), forState: .Normal)
            }
        }
    }
    
    //Envío de datos ---
    @IBAction func sendRateButton_Click(sender: UIButton) {
        if self.comentTextView.textColor == UIColor.blackColor() {
            self.coment = self.comentTextView.text
        }
        let alert = UIAlertController(title: "Confirmar envío", message: "¿Está seguro de que desea enviar la calificación? una vez enviada no podrá modificarla.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Enviar", style: UIAlertActionStyle.Default, handler: {action in
            self.sendRate()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func sendRate(){
        let intId: Int = Int(self.talkId)!
        let attrs: [NSObject : AnyObject] = [
            "id_charla": intId,
            "correo_usuario": self.userId,
            "comentario": self.coment,
            "pregunta": Double(self.rate)
        ]
        self.feature.setAttributes(attrs)
        self.featureLayer.applyEditsWithFeaturesToAdd([feature], toUpdate: nil, toDelete: nil)
        
    }
    
    //Control de capas---->
    
    func setUpGDB(){
        self.featureLayer = AGSFeatureLayer(URL: self.url, mode: .OnDemand)
        self.featureLayer.delegate = self
        self.featureLayer.editingDelegate = self
    }
    
    func layerDidLoad(layer: AGSLayer!) {
        self.sendButton.enabled = true
        self.sendButton.alpha = 1
        self.feature = self.featureLayer.featureWithTemplate(self.featureLayer.templates[0] as! AGSFeatureTemplate)
    }
    
    func layer(layer: AGSLayer!, didFailToLoadWithError error: NSError!) {
        let alert = UIAlertController(title: "Error de conexión", message: "No podemos conectar con el servidor. Por favor verifique su conexión a internet y vuela a intentar.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func featureLayer(featureLayer: AGSFeatureLayer!, operation op: NSOperation!, didFeatureEditsWithResults editResults: AGSFeatureLayerEditResults!) {
        if editResults.addResults == nil{
            let alert = UIAlertController(title: "Error de envío", message: "No se ha podido registrar la calificación", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func featureLayer(featureLayer: AGSFeatureLayer!, operation op: NSOperation!, didFailFeatureEditsWithError error: NSError!) {
        let alert = UIAlertController(title: "Error de conexión", message: "No podemos conectar con el servidor. Por favor verifique su conexión a internet y vuela a intentar.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
