//
//
//  Activity.swift
//  chatspot
//
//  Created by Varun on 10/24/17.
//  Copyright © 2017 g7. All rights reserved.
//
//
//

import Foundation
import FirebaseDatabase

let KEY_CREATED_AT = "createdAt"
let KEY_ACTIVITY_NAME = "activityName"
let KEY_ACTIVITY_DESCRIPTION = "activityDescription"
let KEY_ONGOING = "isOngoing"
let KEY_ACTIVITY_STARTED_BY_NAME = "activityStartedByName"
let KEY_ACTIVITY_STARTED_BY_GUID = "activityStartedByGuid"
let KEY_LATITUDE = "activityLatitude"
let KEY_LONGITUDE = "activityLongitude"
let KEY_USERS_JOINED = "usersJoined"

class Activity {
    
    var guid: String?
    var createdAt: Date?
    var activityName: String?
    var activityDescription: String?
    var isOngoing: Bool?
    var activityStartedByName: String?
    var activityStartedByGuid: String?
    var latitude: Double?
    var longitude: Double?
    var usersJoined = [String:Bool]()
    
    convenience init(activityName: String,
                     activityDescription: String,
                     activityStartedByName: String,
                     activityStartedByGuid: String,
                     latitude: Double?,
                     longitude: Double?) {
        
        self.init()
        self.activityName = activityName
        self.activityDescription = activityDescription
        self.activityStartedByGuid = activityStartedByGuid
        self.activityStartedByName = activityStartedByName
        self.latitude = latitude
        self.longitude = longitude
        self.usersJoined = [activityStartedByGuid : true]
    }
    
    convenience init(guid: String, obj: NSDictionary) {
        
        self.init()
        
        self.guid = guid
        
        if let createdAt = obj[KEY_CREATED_AT] as? Double {
            let epochTime = TimeInterval(createdAt)/1000
            self.createdAt = Date(timeIntervalSince1970: epochTime)
        }
        
        if let activityName = obj[KEY_ACTIVITY_NAME] as? String {
            self.activityName = activityName
        }
        
        if let activityDescription = obj[KEY_ACTIVITY_DESCRIPTION] as? String {
            self.activityDescription = activityDescription
        }
        
        self.isOngoing = obj[KEY_ONGOING] as? Bool ?? false
        
        if let nameStartedBy = obj[KEY_ACTIVITY_STARTED_BY_NAME] as? String {
            self.activityStartedByName = nameStartedBy
        }
        
        if let guidStartedBy = obj[KEY_ACTIVITY_STARTED_BY_GUID] as? String {
            self.activityStartedByGuid = guidStartedBy
        }
        
        if let latitude = obj[KEY_LATITUDE] as? Double {
            self.latitude = latitude
        }
        
        if let longitude = obj[KEY_LONGITUDE] as? Double {
            self.longitude = longitude
        }
        
        if let usersJoined = obj[KEY_USERS_JOINED] as? [String:Bool] {
            self.usersJoined = usersJoined
        }
    }
    
    func toValue() -> [String:Any] {
        
        let value: [String:Any] = [
            
            KEY_CREATED_AT: ServerValue.timestamp(),
            KEY_ACTIVITY_NAME: self.activityName ?? "Unknown",
            KEY_ACTIVITY_DESCRIPTION: self.activityDescription ?? "Unknown",
            KEY_ONGOING: self.isOngoing ?? false,
            KEY_ACTIVITY_STARTED_BY_NAME: self.activityStartedByName ?? "Anonymous",
            KEY_ACTIVITY_STARTED_BY_GUID: self.activityStartedByGuid ?? "",
            KEY_LATITUDE: self.latitude ?? 0,
            KEY_LONGITUDE: self.longitude ?? 0,
            KEY_USERS_JOINED: self.usersJoined
        ]
        
        return value
    }
    
}
