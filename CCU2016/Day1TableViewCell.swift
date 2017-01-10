//
//  Day1TableViewCell.swift
//  CCU2016
//
//  Created by Juan Ríos on 13/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class Day1TableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
