//
//  MessageViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 7/07/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    var moreInfoId: MessageItem = MessageItem()
    
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageBody: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.populateMessage()
    }
    
    func populateMessage(){
        self.messageTitle.text = moreInfoId.title
        self.messageBody.text = moreInfoId.detail
        self.messageBody.textColor = UIColor.whiteColor()
        self.messageBody.textAlignment = .Justified
        self.messageBody.font = UIFont.systemFontOfSize(15)
    }
}
