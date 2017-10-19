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

    static var userGuid: String!
    
    static func createChatRoom(name: String, description: String, banner: String?, longitude: Double, latitude: Double) {
        let room: [String: String] = [
            ChatRoom1.KEY_NAME: name,
            ChatRoom1.KEY_DESCRIPTION: description,
            ChatRoom1.KEY_BANNER: banner ?? "",
            ChatRoom1.KEY_LONGITUDE: longitude.description,
            ChatRoom1.KEY_LATITUDE: latitude.description
        ]
        let ref = Database.database().reference()
        ref.child("chatrooms").childByAutoId().setValue(room)
    }
    
    static func joinChatRoom(userGuid: String, roomGuid: String) {
        let ref = Database.database().reference()
        ref.child("chatrooms").child(roomGuid).child("users").updateChildValues([userGuid: true])
    }
    
    static func leaveChatRoom(userGuid: String, roomGuid: String) {
        let ref = Database.database().reference()
        ref.child("chatrooms").child(roomGuid).child("users").child(userGuid).removeValue()
    }
    
    static func removeObserver(handle: UInt){
        let ref = Database.database().reference()
        ref.removeObserver(withHandle: handle)
    }
    
    static func observeLastMessageChange(success: @escaping (String, String, Double?) -> (), failure: @escaping (Error?) -> ()) -> UInt{
        let chatroomsRef =  Database.database().reference().child("chatrooms")
        
        let userGuid = Auth.auth().currentUser!.uid
        
        let refHandle = chatroomsRef
            .queryOrdered(byChild: "/users/\(userGuid)")
            .queryEqual(toValue: true)
            .observe(.childChanged, with: { (snapshot) in
                let dict = snapshot.value as? NSDictionary ?? [:]
                let room = ChatRoom1(guid: snapshot.key, obj: dict)
                success(room.guid!, room.lastMessage!, room.lastMessageTimestamp)
            }) { (error: Error?) in
                failure(error)
            }
       
        return refHandle
    }
    
    static func observeMyChatRooms(success: @escaping (ChatRoom1) -> (), failure: @escaping (Error?) -> ()) -> UInt{
        let ref = Database.database().reference()
        let chatroomsRef = ref.child("chatrooms")
        
        let userGuid = Auth.auth().currentUser!.uid
        
        let refHandle = chatroomsRef.queryOrdered(byChild: "/users/\(userGuid)").queryEqual(toValue: true).observe(DataEventType.childAdded, with: { (snapshot: DataSnapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            let room = ChatRoom1(guid: snapshot.key, obj: dict)
            success(room)
        }) { (error: Error?) in
            failure(error)
        }
    
        return refHandle
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
    
    static func sendMessage(message: Message1, roomId: String, success: () -> (), failure: () -> ()) {
        let ref = Database.database().reference()
        ref.child("messages").child(roomId).childByAutoId().setValue(message.toValue())
        ref.child("chatrooms").child(roomId).child("lastMessage").setValue(message.message)
        ref.child("chatrooms").child(roomId).child("lastMessageTimestamp").setValue(ServerValue.timestamp())
        success()
    }
    
    //MARK:- User profile
    

    static func updateUserProfile(user: User1) {
        let userData: [String: String] = [
            User1.KEY_DISPLAY_NAME: user.name ?? "",
            User1.KEY_PROFILE_IMAGE: user.profileImage ?? "",
            User1.KEY_BANNER_IMAGE: user.bannerImage ?? "",
            User1.KEY_TAG_LINE: user.tagline ?? "",
        ]
        let ref = Database.database().reference()
        ref.child("users").child(user.guid!).setValue(userData)
    }
    
    static func registerIfNeeded(guid: String, user: FirebaseAuth.User) {
        userGuid = guid
        
        let value: [String: String] = [
            User1.KEY_DISPLAY_NAME: user.displayName!,
            User1.KEY_PROFILE_IMAGE: (user.photoURL?.absoluteString)!
        ]
        let ref = Database.database().reference()
        ref.child("users").child(guid).setValue(value)
    }
    
    static func getUserProfile(userGuid: String, success: @escaping (User1) -> (), failure: @escaping () -> ()) {
        let ref = Database.database().reference()
        
        ref.child("users").child(userGuid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let userDict = snapshot.value as? NSDictionary ?? [:]
            if userDict.count != 0 {
                let user = User1(guid: userGuid, obj: userDict)
                success(user)
            } else {
                failure()
            }
        })
    }
    
}
