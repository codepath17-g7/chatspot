//
//  ChatRoomAnnotationView.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/15/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuthUI

class ChatRoomAnnotationView: MKAnnotationView {
    
    var roomGuid: String {
        get {
            let chatRoomAnnotation = annotation as! ChatRoomAnnotation
            return chatRoomAnnotation.room.guid
        }
    }
    
    init(roomAnnotation: ChatRoomAnnotation, reuseIdentifier: String?) {
        super.init(annotation: roomAnnotation, reuseIdentifier: reuseIdentifier)
        
        let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(joinRoom(_:)), for: .touchUpInside)
        
        image = #imageLiteral(resourceName: "around me")
        rightCalloutAccessoryView = button
        canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func joinRoom(_ sender: Any) {
        print("joining room \(roomGuid)")
        let user = Auth.auth().currentUser!
        ChatSpotClient.joinChatRoom(userGuid: user.uid, roomGuid: roomGuid)

    }
}
