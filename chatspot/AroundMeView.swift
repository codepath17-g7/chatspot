//
//  AroundMeView.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuthUI


class AroundMeView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var rooms: [ChatRoom1] = []
    var observers = [UInt]()
    var aroundMeRoomGuid: String?
    var chats: [String: ChatRoom1] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    private func initSubView() {
        let nib = UINib(nibName: "AroundMeView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        mapView.delegate = self
        centerMap()
        print("Created Map")
        
        ChatSpotClient.getRooms(success: { (rooms: [ChatRoom1]) in
            for room in rooms {
                self.chats[room.guid] = room
            }
            self.rooms = Array(self.chats.values)
            self.reloadMap()
        }) { (error: Error?) in
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if (newWindow != nil) {
            observers.append(ChatSpotClient.observeMyAroundMeRoomGuid(success: { (roomGuid: String) in
                self.aroundMeRoomGuid = roomGuid
                self.reloadMap()
            }) { (error: Error?) in
            })
            
            observers.append(ChatSpotClient.observeChatRooms(success: { (room: ChatRoom1) in
                print("Room \(room.name) has changed")
                self.chats[room.guid] = room
                self.rooms = Array(self.chats.values)
                self.reloadMap()
            }, failure: { (error: Error?) in
                print(error ?? "")
            }))
        } else {
            observers.forEach { ChatSpotClient.removeObserver(handle: $0) }
            observers.removeAll()
        }
    }

}

//MARK:- MKMapViewDelegate
extension AroundMeView: MKMapViewDelegate {
    func reloadMap() {
        
        print("Reloading map with \(rooms.count) rooms")
        mapView.removeAnnotations(mapView.annotations)

        for room in rooms {
            let annotation = ChatRoomAnnotation(room: room, coordinate:
                CLLocationCoordinate2D(latitude: room.latitude!, longitude: room.longitude!))
            
            mapView.addAnnotation(annotation)
        }
        
//        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func centerMap() {
        let rgn = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(37.5644565, -122.1683781), 65000, 65000);
        mapView.setRegion(rgn, animated: false)
        mapView.isZoomEnabled = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true
    }
    

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let chatRoomAnnotation = annotation as! ChatRoomAnnotation
        var annotationView :ChatRoomAnnotationView?
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: chatRoomAnnotation.room.guid) as? ChatRoomAnnotationView
        
        if annotationView == nil {
            annotationView = ChatRoomAnnotationView(roomAnnotation: chatRoomAnnotation, reuseIdentifier: chatRoomAnnotation.room.guid)
            
            if chatRoomAnnotation.isUserNearBy() {
                annotationView?.image = #imageLiteral(resourceName: "map_pin_nearby")
            } else if chatRoomAnnotation.isUserJoined() {
                annotationView?.image = #imageLiteral(resourceName: "map_pin_joined")
            } else {
                annotationView?.image = #imageLiteral(resourceName: "pin")
            }
        } else {
            annotationView?.annotation = chatRoomAnnotation
        }
        
        annotationView?.configureDetailView()
        return annotationView
    }
}
