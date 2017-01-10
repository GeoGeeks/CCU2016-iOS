//
//  SideMenuICell.swift
//  CCU2016
//
//  Created by Juan Ríos on 18/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class SideMenuICell: UITableViewCell {
    
    @IBOutlet weak var simage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    

}
