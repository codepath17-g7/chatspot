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
    }
    
    func updateRooms(_ rooms: [ChatRoom1]) {
        self.rooms = rooms
        reloadMap()
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
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: chatRoomAnnotation.room.guid) as? ChatRoomAnnotationView
        
        if annotationView == nil {
            annotationView = ChatRoomAnnotationView(roomAnnotation: chatRoomAnnotation, reuseIdentifier: chatRoomAnnotation.room.guid)
        } else {
            annotationView?.annotation = chatRoomAnnotation
        }
        
        annotationView?.configureDetailView()

        return annotationView
    }
}
