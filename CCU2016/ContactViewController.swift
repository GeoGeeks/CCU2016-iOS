//
//  ContactViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 29/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit
import AddressBookUI

class ContactViewController:
UIViewController,
UITableViewDataSource,
//ABNewPersonViewControllerDelegate,
UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    func newPersonViewController(newPersonView: ABNewPersonViewController, didCompleteWithNewPerson person: ABRecord?) {
        newPersonView.navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    var contactsGropus:[ContactGroup]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactsGropus = []
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.populateTable()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.contactsGropus.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactsGropus[section].contacts.count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.contactsGropus[indexPath.section].collapsed == true && indexPath.row != 0{
            return 0
        } else if indexPath.row == 0{
            return 45
        }else{
            return 60
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.contactsGropus[indexPath.section].collapsed = !self.contactsGropus[indexPath.section].collapsed
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TalkHeaderCell
            if self.contactsGropus[indexPath.section].collapsed == false{
                cell.himage?.image = UIImage(named: "boton_cerrar")
            }else{
                cell.himage?.image = UIImage(named: "boton_abrir")
            }
        } else {
            if self.contactsGropus[indexPath.section].contacts[indexPath.row - 1].Url != "(+57) 310 481 3554"{
                let url = NSURL(string: contactsGropus[indexPath.section].contacts[indexPath.row - 1].Url)!
                UIApplication.sharedApplication().openURL(url)
            }else if self.contactsGropus[indexPath.section].contacts[indexPath.row - 1].Url == "(+57) 310 481 3554"{
                UIPasteboard.generalPasteboard().string = self.contactsGropus[indexPath.section].contacts[indexPath.row - 1].Url
                
                let alert = UIAlertController(title: "Copiado", message: "El número se ha guardado en el portapapeles ", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
//                let controller = ABNewPersonViewController()
//                
//                let person: ABRecordRef = ABPersonCreate().takeRetainedValue()
//                ABRecordSetValue(person, kABPersonFirstNameProperty, "Esri Colombia" as CFTypeRef, nil)
//                //ABRecordSetValue(person, kABPersonPhoneProperty, "+573104813554" as CFTypeRef, nil)
//                let phoneNumbers: ABMutableMultiValue =
//                    ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
//                ABMultiValueAddValueAndLabel(phoneNumbers, "+573104813554", kABPersonPhoneMainLabel, nil)
//                ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumbers, nil)
//                controller.newPersonViewDelegate = self
//                controller.displayedPerson = person
//                let navigationController = UINavigationController(rootViewController: controller)
//                self.presentViewController(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = self.tableView.dequeueReusableCellWithIdentifier("CeldaContacto", forIndexPath: indexPath) as! TalkHeaderCell
            cell.hlabel.text = self.contactsGropus[indexPath.section].name
            return cell
        }else{
            let cell = self.tableView.dequeueReusableCellWithIdentifier("CeldaContactoIn", forIndexPath: indexPath)
            cell.imageView?.image = UIImage(named: self.contactsGropus[indexPath.section].contacts[indexPath.row - 1].image)
            cell.textLabel?.text = self.contactsGropus[indexPath.section].contacts[indexPath.row - 1].nombre
            return cell
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func populateTable(){
        let esrico = ContactGroup()
        esrico.name = "Esri Colombia"
        esrico.collapsed = true
        
        let esriSite = Contact()
        esriSite.nombre = "Visita nuestro web site"
        esriSite.Url = "http://www.esri.co/esri/"
        esriSite.image = "contacto_web"
        esrico.contacts.append(esriSite)
        
        let esriFace = Contact()
        esriFace.nombre = "Síguenos en Facebook"
        esriFace.Url = "https://www.facebook.com/EsriColombiaSAS"
        esriFace.image = "contacto_facebook"
        esrico.contacts.append(esriFace)
        
        let esriTwit = Contact()
        esriTwit.nombre = "Síguenos en Twitter"
        esriTwit.Url = "https://mobile.twitter.com/esricol"
        esriTwit.image = "contacto_twitter"
        esrico.contacts.append(esriTwit)
        
        let esriYoutube = Contact()
        esriYoutube.nombre = "Síguenos en Youtube"
        esriYoutube.Url = "https://www.youtube.com/user/ProsisCom"
        esriYoutube.image = "contacto_youtube"
        esrico.contacts.append(esriYoutube)
        
        let esriLinke = Contact()
        esriLinke.nombre = "Únete a nuestro Linkedin"
        esriLinke.Url = "https://www.linkedin.com/company/esri-colombia"
        esriLinke.image = "contacto_linkedin"
        esrico.contacts.append(esriLinke)
        
        let esriCorreo = Contact()
        esriCorreo.nombre = "Escríbenos a nuestro correo"
        esriCorreo.Url = "http://www.esri.co/esri/info/contactenos.html"
        esriCorreo.image = "contacto_correo"
        esrico.contacts.append(esriCorreo)
        
        let esriWA = Contact()
        esriWA.nombre = "Escríbenos a (+57) 310 481 3554"
        esriWA.Url = "(+57) 310 481 3554"
        esriWA.image = "whatsapp-32"
        esrico.contacts.append(esriWA)
        
        self.contactsGropus.append(esrico)
        
        //        GeoGeeks
        
        let geoGeeks = ContactGroup()
        geoGeeks.name = "GeoGeeks"
        geoGeeks.collapsed = true
        
        let geoGeeksSite = Contact()
        geoGeeksSite.nombre = "Visita nuestro web site"
        geoGeeksSite.Url = "http://desarrolladores.esri.co/"
        geoGeeksSite.image = "contacto_web"
        geoGeeks.contacts.append(geoGeeksSite)
        
        let geoGeeksFace = Contact()
        geoGeeksFace.nombre = "Síguenos en Facebook"
        geoGeeksFace.Url = "https://www.facebook.com/geogeeksco/"
        geoGeeksFace.image = "contacto_facebook"
        geoGeeks.contacts.append(geoGeeksFace)
        
        let geoGeeksTwit = Contact()
        geoGeeksTwit.nombre = "Síguenos en Twitter"
        geoGeeksTwit.Url = "https://twitter.com/geo_geeks"
        geoGeeksTwit.image = "contacto_twitter"
        geoGeeks.contacts.append(geoGeeksTwit)
        
        let geoGeeksYoutu = Contact()
        geoGeeksYoutu.nombre = "Síguenos en Youtube"
        geoGeeksYoutu.Url = "https://www.youtube.com/channel/UCuGsuNbUykWZ6lsb85PeW0A"
        geoGeeksYoutu.image = "contacto_youtube"
        geoGeeks.contacts.append(geoGeeksYoutu)
        
        let geoGeeksGit = Contact()
        geoGeeksGit.nombre = "Consulta nuestro GitHub"
        geoGeeksGit.Url = "https://github.com/GeoGeeks"
        geoGeeksGit.image = "contacto_github"
        geoGeeks.contacts.append(geoGeeksGit)
        
        let geoGeeksGaleri = Contact()
        geoGeeksGaleri.nombre = "Visita nuestra galeria"
        geoGeeksGaleri.Url = "http://geoapps.esri.co/mapGallery/"
        geoGeeksGaleri.image = "contacto_galeria"
        geoGeeks.contacts.append(geoGeeksGaleri)
        
        let geoGeeksCorreo = Contact()
        geoGeeksCorreo.nombre = "Escríbenos a nuestro correo"
        geoGeeksCorreo.Url = "http://desarrolladores.esri.co/semillero.html#contacto"
        geoGeeksCorreo.image = "contacto_correo"
        geoGeeks.contacts.append(geoGeeksCorreo)
        
        let planetaEsriUrl = Contact()
        planetaEsriUrl.nombre = "Visita la web de Planeta Esri"
        planetaEsriUrl.Url = "http://geoapps.esri.co/planetaesri2016"
        planetaEsriUrl.image = "contacto_web"
        geoGeeks.contacts.append(planetaEsriUrl)
        
        self.contactsGropus.append(geoGeeks)
    }
    
    class ContactGroup {
        var collapsed:Bool!
        var name:String!
        var contacts:[Contact] = []
    }
    
    class Contact{
        var image:String!
        var nombre:String!
        var Url:String!
    }
    
}

