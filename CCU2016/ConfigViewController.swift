//
//  ConfigViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 29/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet weak var textoAyuda: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ocultarMostrarAyuda(sender: UISwitch) {
        if sender.on{
            UIView.animateWithDuration(0.4, animations: {
                self.textoAyuda.alpha = 1
                }, completion:  nil
            )
        } else {
            UIView.animateWithDuration(0.4, animations: {
                self.textoAyuda.alpha = 0
                }, completion: nil)
        }
    }
}
