//
//  SideMenuTableViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 29/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class SideMenuTableViewController: UITableViewController {
    
    var menuItems: [SideMenuItem]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.menuItems = []
        self.populateTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuICell", forIndexPath: indexPath) as! SideMenuICell
        cell.label.text = menuItems[indexPath.row].name
        cell.simage.image = UIImage(named: menuItems[indexPath.row].image)
        cell.simage.contentMode = UIViewContentMode.ScaleAspectFill
        cell.separator.layer.cornerRadius = 2
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let cell = tableView.cellForRowAtIndexPath(indexPath)
        switch(indexPath.row){
        case 0:
            self.navigate("ViewController")
            break
        case 1:
            self.navigate("AccountViewController")
            break
        case 2:
            self.navigate("MessagesViewController")
            break
//        case 3:
//            self.navigate("PartnersViewController")
//            break
        case 3:
            self.navigate("SponsorsViewController")
            break
        case 4:
            self.navigate("ConfigViewController")
            break
        default:
            self.navigate("ContactViewController")
            break
        }
    }
    
    func navigate(restorationId:String){
        if self.navigationController?.visibleViewController?.restorationIdentifier != restorationId{
            let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier(restorationId)
            self.navigationController!.pushViewController(secondViewController, animated: true)
        }
    }
    
    func populateTable(){
        let index = SideMenuItem()
        index.name = "Inicio"
        index.image = "menu_inicio-99"
        self.menuItems.append(index)
        
        let account = SideMenuItem()
        account.name = "Cuenta"
        account.image = "menu_cuenta"
        self.menuItems.append(account)
        
        let messages = SideMenuItem()
        messages.name = "Mensajes"
        messages.image = "menu_mensajes"
        self.menuItems.append(messages)
        
//        let partners = SideMenuItem()
//        partners.name = "Partners"
//        partners.image = "menu_partners"
//        self.menuItems.append(partners)
        
        let sponsors = SideMenuItem()
        sponsors.name = "Patrocinadores"
        sponsors.image = "menu_patrocinadores"
        self.menuItems.append(sponsors)
        
        let config = SideMenuItem()
        config.name = "Configuración"
        config.image = "menu_configuracion"
        self.menuItems.append(config)
        
        let contact = SideMenuItem()
        contact.name = "Contáctenos"
        contact.image = "menu_contacto"
        self.menuItems.append(contact)

        
    }
    
    class SideMenuItem{
        var name: String!
        var image: String!
    }
}
