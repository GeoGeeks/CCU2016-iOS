//
//  AccountViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 29/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import ArcGIS

class AccountViewController: UIViewController, UITextFieldDelegate, AGSLayerDelegate, AGSFeatureLayerEditingDelegate{
    
    @IBOutlet weak var contIniCuenta: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var logedInView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    var myStrings:[String]!
    var userInfo:UserInfoViewController!
    let url = NSURL(string: "http://54.187.22.10:6080/arcgis/rest/services/CCU2016/tablas_editables_CCU_2016/FeatureServer/3")
    var featureLayer :AGSFeatureLayer!
    var feature: AGSGraphic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.enabled = false
        self.leerDatos()
        self.setUpGDB()
        
        self.nameTextField.delegate = self
        self.companyTextField.delegate = self
        self.emailTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueDatosUsuario"{
            if let destinationVC = segue.destinationViewController as? UserInfoViewController{
                self.userInfo = destinationVC
            }
        }
    }
    @IBAction func loginButton_Click(sender: UIButton) {
        if self.nameTextField.text != "" && self.companyTextField.text != "" && self.emailTextField != ""{
            let attrs = ["nombre_usuario":self.nameTextField.text!, "correo_usuario":self.emailTextField.text!, "empresa_usuario":self.companyTextField.text!]
            feature.setAttributes(attrs)
            self.featureLayer.applyEditsWithFeaturesToAdd([feature], toUpdate: nil, toDelete: nil)
        }else{
            let alert = UIAlertController(title: "Error de registro", message: "Todos los campos son obligatorios.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func leerDatos(){
        let directorio = NSFileManager.defaultManager()
        do{
            let fileurl = try directorio.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            let file = fileurl.URLByAppendingPathComponent("datosUsuario.txt")
            if directorio.fileExistsAtPath(file.path!){
                self.logedInView.hidden = false
                self.contIniCuenta.hidden = true
                let datosCont = try String(contentsOfURL: file, encoding: NSUTF8StringEncoding)
                myStrings = datosCont.componentsSeparatedByString(",")
                self.userInfo.userNameLabel.text = myStrings[0]
                self.userInfo.userCompanyLabel.text = myStrings[1]
                self.userInfo.userMailLabel.text = myStrings[2]
            }
        }
        catch{
            let alert = UIAlertController(title: "Error de registro", message: "Por favor intente más tarde.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func setUpGDB(){
        self.featureLayer = AGSFeatureLayer(URL: self.url, mode: .OnDemand)
        self.featureLayer.delegate = self
        self.featureLayer.editingDelegate = self
    }
    
    func layerDidLoad(layer: AGSLayer!) {
        self.loginButton.enabled = true
        self.loginButton.alpha = 1
        self.feature = self.featureLayer.featureWithTemplate(self.featureLayer.templates[0] as! AGSFeatureTemplate)
    }
    
    func layer(layer: AGSLayer!, didFailToLoadWithError error: NSError!) {
        let alert = UIAlertController(title: "Error de registro", message: "No podemos conectar con el servidor. Por favor verifique su conexión a internet y vuela a intentar", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func featureLayer(featureLayer: AGSFeatureLayer!, operation op: NSOperation!, didFeatureEditsWithResults editResults: AGSFeatureLayerEditResults!) {
        if editResults.addResults == nil{
            let alert = UIAlertController(title: "Error de registro", message: "Ya se ha registrado esta cuenta de correo.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let datosUsuario = self.nameTextField.text! + "," + self.companyTextField.text! + "," + self.emailTextField.text!
            let dir = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create:true)
            let file = dir.URLByAppendingPathComponent("datosUsuario.txt")
            
            do{
                try datosUsuario.writeToURL(file, atomically: true, encoding: NSUTF8StringEncoding)
                self.leerDatos()
                
            }
            catch {
                let alert = UIAlertController(title: "Error de registro", message: "Por favor intente más tarde.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func featureLayer(featureLayer: AGSFeatureLayer!, operation op: NSOperation!, didFailFeatureEditsWithError error: NSError!) {
        let alert = UIAlertController(title: "Error de registro", message: "No podemos conectar con el servidor. Por favor verifique su conexión a internet y vuela a intentar", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
