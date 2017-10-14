//
//  ChatSpotClient.swift
//  chatspot
//
//  Created by Syed Hakeem Abbas on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class ChatSpotClient {


    static func removeObserver(handle: UInt){
        let ref = Database.database().reference()
        ref.removeObserver(withHandle: handle)
    }
    
    static func observeChatRooms(success: @escaping ([ChatRoom]) -> ()) -> UInt{
        let ref = Database.database().reference()
        let chatroomsRef = ref.child("chatrooms")
        let refHandle = chatroomsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(postDict)
            let rooms = [ChatRoom]()
            success(rooms)
        })
        return refHandle
    }
}
