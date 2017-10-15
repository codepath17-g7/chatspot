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
            ChatRoom1.KEY_NAME: name,
            ChatRoom1.KEY_DESCRIPTION: description,
            ChatRoom1.KEY_BANNER: banner ?? ""
        ]
        let ref = Database.database().reference()
        ref.child("chatrooms").childByAutoId().setValue(room)
    }
    
    static func removeObserver(handle: UInt){
        let ref = Database.database().reference()
        ref.removeObserver(withHandle: handle)
    }
    
    static func observeChatRooms(success: @escaping (ChatRoom1) -> (), failure: @escaping (Error?) -> ()) -> UInt{
        let ref = Database.database().reference()
        let chatroomsRef = ref.child("chatrooms")
        
        let refHandle = chatroomsRef.queryOrderedByKey().observe(DataEventType.childAdded, with: { (snapshot: DataSnapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            let room = ChatRoom1(guid: snapshot.key, obj: dict)
            success(room)
        }) { (error: Error?) in
            failure(error)
        }
    
        return refHandle
    }
    
    static func observeNewMessages(roomId: String, success: @escaping (Message1) -> (), failure: () -> ()) -> UInt{
        let ref = Database.database().reference()
        let chatRef = ref.child("messages").child(roomId)
        let refHandle = chatRef.observe(DataEventType.childAdded, with: { (snapshot) in
            let postDict = snapshot.value as? NSDictionary ?? [:]
            let message = Message1(guid: snapshot.key, obj: postDict)
            success(message)
        })
        return refHandle
    }
    
    static func getMessagesForRoom(roomId: String, success: @escaping ([Message1]) -> (), failure: @escaping (Error?) -> ()) {
        let ref = Database.database().reference()
        let chatRef = ref.child("messages").child(roomId)
        
        chatRef.queryOrderedByKey().observeSingleEvent(of: DataEventType.value, with: { (snapshot: DataSnapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(postDict)
            let messages = Message1.messagesWithArray(dicts: postDict)
            success(messages)
        }) { (error: Error) in
            failure(error)
        }
    }
    
    static func registerIfNeeded(guid: String, user: FirebaseAuth.User) {
        let value: [String: String] = [
            User1.KEY_DISPLAY_NAME: user.displayName!,
            User1.KEY_PROFILE_IMAGE: (user.photoURL?.absoluteString)!
        ]
        let ref = Database.database().reference()
        ref.child("users").child(guid).setValue(value)
    }
    
    static func sendMessage(message: Message1, roomId: String, success: () -> (), failure: () -> ()) {
        let ref = Database.database().reference()
        ref.child("messages").child(roomId).childByAutoId().setValue(message.toValue())
        success()
    }
}
