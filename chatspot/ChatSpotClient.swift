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

    static func createChatRoom(name: String, description: String, banner: String?) {
        let room: [String: String] = [
            ChatRoom.KEY_NAME: name,
            ChatRoom.KEY_DESCRIPTION: description,
            ChatRoom.KEY_BANNER: banner ?? ""
        ]
        let ref = Database.database().reference()
        ref.child("chatrooms").childByAutoId().setValue(room)
    }
    
    static func removeObserver(handle: UInt){
        let ref = Database.database().reference()
        ref.removeObserver(withHandle: handle)
    }
    
    static func observeChatRooms(success: @escaping ([ChatRoom]) -> (), failure: () -> ()) -> UInt{
        let ref = Database.database().reference()
        let chatroomsRef = ref.child("chatrooms")
        let refHandle = chatroomsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(postDict)
            let rooms = ChatRoom.roomsWithArray(dicts: postDict)
            success(rooms)
        })
        return refHandle
    }
    
    static func registerIfNeeded(guid: String, user: FirebaseAuth.User) {
        let value: [String: String] = [
            User.KEY_DISPLAY_NAME: user.displayName!,
            User.KEY_PROFILE_IMAGE: (user.photoURL?.absoluteString)!
        ]
        let ref = Database.database().reference()
        ref.child("users").child(guid).setValue(value)
    }
}
