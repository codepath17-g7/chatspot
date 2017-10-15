//
//  LocationManager.swift
//  chatspot
//
//  Created by Varun on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import CoreLocation

// let locationChangeNotification = Notification.Name("locationChangeNotification")

class LocationManager: NSObject {
    
    static let instance = LocationManager()
    
    private let manager: CLLocationManager = CLLocationManager()
    
    override private init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }
    
    func listenForSignificantLocationChanges() {
        print("listenForSignificantLocationChanges")
        manager.requestAlwaysAuthorization()
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func listenForRealtimeLocationChanges() {
        print("listenForRealtimeLocationChanges")
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func stopListeningRealtimeLocation() {
        print("stopListeningRealtimeLocation")
        manager.stopUpdatingLocation()
    }
    
    func stopListeningSignificantChanges() {
        print("stopListeningSignificantChanges")
        manager.stopMonitoringSignificantLocationChanges()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // TODO something when location authorization changes
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // NotificationCenter.default.post(name: locationChangeNotification, object: locations.last)
        print(locations.last?.coordinate ?? "No location?")
        // TODO: send location to server
    }
    
}
