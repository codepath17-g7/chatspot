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
    var detailView: ChatRoomAnnotationDetailView!
    
    var roomGuid: String {
        get {
            let chatRoomAnnotation = annotation as! ChatRoomAnnotation
            return chatRoomAnnotation.room.guid
        }
    }
    
    init(roomAnnotation: ChatRoomAnnotation, reuseIdentifier: String?) {
        super.init(annotation: roomAnnotation, reuseIdentifier: reuseIdentifier)
        
        detailView = ChatRoomAnnotationDetailView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        detailView.translatesAutoresizingMaskIntoConstraints = false
        detailView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        detailView.joinButton.addTarget(self, action: #selector(joinRoom(_:)), for: .touchUpInside)
        detailCalloutAccessoryView = detailView
        
        image = #imageLiteral(resourceName: "around me")
        canShowCallout = true
    }
    

    func configureDetailView() {
        let width = 200
        let height = 150
       
        let options = MKMapSnapshotOptions()
        options.size = CGSize(width: width, height: height)
        options.mapType = .satelliteFlyover
        options.camera = MKMapCamera(lookingAtCenter: self.annotation!.coordinate, fromDistance: 250, pitch: 65, heading: 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if snapshot != nil {
                self.detailView.roomImage.image = snapshot!.image
            }
        }
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
