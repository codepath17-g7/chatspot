//
//  AroundMeView.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import MapKit

class AroundMeView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
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

        centerMap()
    }
    
    func updateRooms(_ rooms: [ChatRoom1]) {
        
    }

}

extension AroundMeView: MKMapViewDelegate {
    func reloadMap() {
    }
    
    func centerMap() {
        let rgn = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(37.7833, -122.4067), 2000, 2000);
        mapView.setRegion(rgn, animated: false)
        mapView.isZoomEnabled = true
        mapView.showsCompass = true
        
    }
}
