//
//  SpeakerTableViewCell.swift
//  CCU2016
//
//  Created by Juan Ríos on 1/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class SpeakerTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var contact: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
