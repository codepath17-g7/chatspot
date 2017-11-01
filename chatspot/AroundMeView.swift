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


@objc protocol AroundMeViewDelegate {
    func mapPinButtonClicked(roomGuid: String)
    func hideDrawer()
}


class AroundMeView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var reCenter: UIImageView!
    var rooms: [ChatRoom1] = []
    var observers = [UInt]()
//    var aroundMeRoomGuid: String?
    var chats: [String: ChatRoom1] = [:]
    var delegate: AroundMeViewDelegate!

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

        reCenter.layer.masksToBounds = true
        reCenter.setRadiusWithShadow()
        




        
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if (newWindow != nil) {
            print("Map - Adding observer")

            let observer1 = ChatSpotClient.observeMyAroundMeRoomGuid(success: { (roomGuid: String?) in
//                self.aroundMeRoomGuid = roomGuid!
                self.reloadMap()
            }) { (error: Error?) in
            }
            print("Map - Adding observer \(observer1)")
            observers.append(observer1)
            
            let observer2 = ChatSpotClient.observeChatRooms(success: { (room: ChatRoom1) in
                print("Map - Room \(room.name!) has changed")
                self.chats[room.guid] = room
                self.rooms = Array(self.chats.values)
                self.reloadMap()
            }, failure: { (error: Error?) in
                print(error ?? "")
            })
            print("Map - Adding observer \(observer2)")
            observers.append(contentsOf: observer2)
        } else {
            print("Map - Removing observer \(observers)")
            observers.forEach { ChatSpotClient.removeObserver(handle: $0) }
            observers.removeAll()
        }
    }

    
    @IBAction func onRecenterMap(_ sender: UITapGestureRecognizer) {
        print("Recenter map")
        let rgn = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 65000, 65000);
        mapView.setRegion(rgn, animated: true)
    }
    
    @IBAction func didTapAwayFromDrawer(_ sender: UITapGestureRecognizer) {
        delegate.hideDrawer()
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (view.annotation is MKUserLocation) {
            return
        }
        
        let annotation = view.annotation as! ChatRoomAnnotation
        let guid = annotation.room.guid
        delegate.mapPinButtonClicked(roomGuid: guid!)
    }
    
    
    

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let chatRoomAnnotation = annotation as! ChatRoomAnnotation
        var annotationView :MKAnnotationView?
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: chatRoomAnnotation.room.guid) as? ChatRoomAnnotationView
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: chatRoomAnnotation.room.guid)
        if annotationView == nil {
//            annotationView = ChatRoomAnnotationView(roomAnnotation: chatRoomAnnotation, reuseIdentifier: chatRoomAnnotation.room.guid)
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: chatRoomAnnotation.room.guid)
        } else {
            annotationView?.annotation = chatRoomAnnotation
        }
        
        if chatRoomAnnotation.isUserNearBy() {
            annotationView?.image = #imageLiteral(resourceName: "PaddedAroundMeMapPin")
        } else if chatRoomAnnotation.isUserJoined() {
            annotationView?.image = #imageLiteral(resourceName: "PaddedBlueMapPin")
        } else {
            annotationView?.image = #imageLiteral(resourceName: "PaddedRedMapPin")
        }
        annotationView?.centerOffset = CGPoint(x: 0, y: (annotationView?.image?.size.height)! / -2);
//        annotationView?.configureDetailView()
        return annotationView
    }
}

extension UIView {

    func setRadiusWithShadow(_ radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
    }
    
}
