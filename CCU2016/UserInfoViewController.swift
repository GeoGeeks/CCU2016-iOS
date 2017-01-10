//
//  UserInfoViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 12/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCompanyLabel: UILabel!
    @IBOutlet weak var userMailLabel: UILabel!
    
    @IBAction func goIndexButton_Click(sender: UIButton) {
        let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ViewController")
        self.navigationController!.pushViewController(secondViewController, animated: true)
    }
}
