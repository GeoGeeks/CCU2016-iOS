//
//  MessageTableViewCell.swift
//  CCU2016
//
//  Created by Juan Ríos on 7/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var identificadorCirculo: UIImageView!
    @IBOutlet weak var indicadorFlecha: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
