//
//  BottomMenuViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 30/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class BottomMenuViewController: UIViewController {

    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var talksButton: UIButton!
    @IBOutlet weak var planetButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBottomBar()
    }

    @IBAction func goToMapButton_Click(sender: UIButton) {
        self.navigate("MapViewController")
    }
    
    @IBAction func goToTalksButton_Click(sender: UIButton) {
        self.navigate("TalksViewController")
    }
    @IBAction func goToPlanetButton_Click(sender: UIButton) {
        self.navigate("PlanetEsriViewController")
    }
    @IBAction func goToFavoritesButton_Click(sender: UIButton) {
        self.navigate("FavoritesViewController")
    }
    func navigate(restorationId:String){
        if self.navigationController?.visibleViewController?.restorationIdentifier != restorationId{
            let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier(restorationId)
            self.navigationController!.pushViewController(secondViewController, animated: true)
        }
    }
    
    func setupBottomBar(){
        self.mapButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.talksButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.planetButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.favButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    }
}
