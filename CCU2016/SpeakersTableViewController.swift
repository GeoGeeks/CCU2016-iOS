//
//  SpeakersTableViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 1/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class SpeakersTableViewController: UITableViewController {
    var speakers: [SpeakerItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.populateTable()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speakers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SpeakerCell", forIndexPath: indexPath) as! SpeakerTableViewCell
        let row = indexPath.row
        let speaker = speakers[row]
        
        cell.name.text = speaker.name
        cell.company.text = speaker.company
        cell.contact.text = speaker.contact
        
        return cell
    }
    
    func populateTable(){
        let juan = SpeakerItem()
        juan.name = "Juan Ríos"
        juan.company = "Esri Colombia"
        juan.contact = "@juan"
        speakers.append(juan)
        let angie = SpeakerItem()
        angie.name = "Angie Rodríguez"
        angie.company = "Esri Colombia"
        angie.contact = "@angie"
        speakers.append(angie)
        self.tableView.reloadData()
    }
    
}
