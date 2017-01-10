//
//  TalkItem.swift
//  CCU2016
//
//  Created by Juan Ríos on 30/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import Foundation

class TalkItem{
    var talkId: String!
    var title: String!
    var timeBeg: String!
    var timeEnd: String!
    var room: String!
    var roomId: String!
    var description: String!
    var speakers: [SpeakerItem] = []
}
