//
//  RoomItem.swift
//  CCU2016
//
//  Created by Juan Ríos on 30/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import Foundation

class RoomItem {
    var roomId: String!
    var name: String!
    var collapsed: Bool!
    var talks: [TalkItem] = []
}