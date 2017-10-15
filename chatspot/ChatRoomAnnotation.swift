//
//  ChatRoomAnnotation.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/15/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class ChatRoomAnnotation: MKPointAnnotation {
    var room: ChatRoom1!
    init(room: ChatRoom1, coordinate: CLLocationCoordinate2D) {
        super.init()
        self.room = room
        self.coordinate = coordinate
        self.title = room.name
    }
    
}
