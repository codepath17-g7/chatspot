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
    static var currentUser: User1!
    static var chatrooms: [String:ChatRoom1] = [:]
    
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

    //MARK:- Activity
    static func createActivtyForChatRoom(roomGuid: String, activity: Activity,
                                         success: @escaping () -> (), failure: @escaping () -> ()) {
        
        let ref = Database.database().reference()
        
        let newActivityGuid = ref.child("activities").child(roomGuid).childByAutoId().key
        
        ref.child("activities")
            .child(roomGuid)
            .child(newActivityGuid)
            .setValue(activity.toValue()) { (error, ref) in
                if (error != nil) {
                    failure()
                } else {
                    success()
                }
        }
    }
    
    static func joinActivity(roomGuid: String, activityGuid: String, userGuid: String,
                             success: @escaping () -> (), failure: @escaping () -> ()) {
        
        let ref = Database.database().reference()
        
        ref.child("activities")
            .child(roomGuid)
            .child(activityGuid)
            .child(KEY_USERS_JOINED)
            .child(userGuid)
            .setValue(true) { (error, ref) in
                if (error != nil) {
                    failure()
                } else {
                    success()
                }
        }
    }
    
    static func leaveActivity(roomGuid: String, activityGuid: String, userGuid: String,
                              success: @escaping () -> (), failure: @escaping () -> ()) {
        
        let ref = Database.database().reference()
        
        ref.child("activities")
            .child(roomGuid)
            .child(activityGuid)
            .child(KEY_USERS_JOINED)
            .child(userGuid)
            .removeValue() {(error, ref) in
                if (error != nil) {
                    failure()
                } else {
                    success()
                }
        }
    }
    
    static func getOngoingActivities(roomGuid: String, success: @escaping ([Activity]) -> ()) {
        
        let ref = Database.database().reference()
        
        ref.child("activities")
            .child(roomGuid)
            .queryOrdered(byChild: KEY_ONGOING)
            .queryEqual(toValue: true)
            .observe(.value, with: { (snapshot) in
                
                let activityDicts = snapshot.value as? [String : AnyObject] ?? [:]
                
                var activities = [Activity]()
                
                for dict in activityDicts {
                    let activity =  Activity(guid: dict.key, obj: dict.value as! NSDictionary)
                    activities.append(activity)
                }
                
                success(activities)
            })
    }

    static func removeObserver(handle: UInt){
        print("Removing observers \(handle)")
        let ref = Database.database().reference()
        ref.removeObserver(withHandle: handle)
    }
    
    static func saveUnreadCount(forChatroom guid: String, count: Int) {
        let ref =  Database.database().reference()
        ref.child("users/\(currentUser.guid!)/\(User1.KEY_UNREAD_COUNT)").updateChildValues([guid: count])
    }
    
    static func getUnreadCount(success: @escaping ([String: Int]) -> ()) {
        let ref =  Database.database().reference()
        ref.child("users").child(currentUser.guid!).child(User1.KEY_UNREAD_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? [String: Int] ?? [String: Int]()
            success(data)
        })
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
                success(room.guid!, room.lastMessage, room.lastMessageTimestamp)
            }) { (error: Error?) in
                failure(error)
            }
       
        return refHandle
    }
    
    //MARK:- ChatRoom
    
    
    static func observeMyAroundMeRoomGuid(success: @escaping (String) -> (), failure: @escaping (Error?) -> ()) -> UInt{
        let chatroomsRef = Database.database().reference().child("users").child(userGuid).child("aroundMe")
        
        return chatroomsRef.queryOrderedByKey().observe(.value, with: { (snapshot: DataSnapshot) in
            let roomGuid = snapshot.value as! String
            success(roomGuid)
        }) { (error: Error?) in
            failure(error)
        }
    }

    static func observeMyChatRooms(onAdd: @escaping (ChatRoom1) -> (), onRemove: @escaping (ChatRoom1) -> (),
                                   addFailure: @escaping (Error?) -> (), removeFailure: @escaping (Error?) -> ()) -> [UInt]{
        
        let ref = Database.database().reference()
        let chatroomsRef = ref.child("chatrooms")
        
        let userGuid = Auth.auth().currentUser!.uid
        
        let addRefHandle = chatroomsRef.queryOrdered(byChild: "/users/\(userGuid)").queryEqual(toValue: true).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            let room = ChatRoom1(guid: snapshot.key, obj: dict)
            onAdd(room)
        }) { (error: Error?) in
            addFailure(error)
        }
        
        let removeRefHadle = chatroomsRef.queryOrdered(byChild: "/users/\(userGuid)").queryEqual(toValue: true).observe(.childRemoved, with: { (snapshot: DataSnapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            let room = ChatRoom1(guid: snapshot.key, obj: dict)
            onRemove(room)
        }) { (error: Error?) in
            removeFailure(error)
        }
        
        return [addRefHandle, removeRefHadle]
    }
    
    static func observeChatRooms(success: @escaping (ChatRoom1) -> (), failure: @escaping (Error?) -> ()) -> UInt{
        let ref = Database.database().reference()
        let chatroomsRef = ref.child("chatrooms")
        
        let refHandle = chatroomsRef.queryOrderedByKey().observe(DataEventType.childChanged, with: { (snapshot: DataSnapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            let room = ChatRoom1(guid: snapshot.key, obj: dict)
            // cache
            chatrooms[room.guid] = room
            success(room)
        }) { (error: Error?) in
            failure(error)
        }
        
        return refHandle
    }
    
    static func getRooms(success: @escaping ([ChatRoom1]) -> (), failure: @escaping (Error?) -> ()) {
        let ref = Database.database().reference()
        let chatRef = ref.child("chatrooms")
        chatRef.queryOrderedByKey().observeSingleEvent(of: DataEventType.value, with: { (snapshot: DataSnapshot) in
            let roomDicts = snapshot.value as? [String : AnyObject] ?? [:]
            let rooms = ChatRoom1.roomsWithArray(dicts: roomDicts)
            
            // add to cache
            for room in rooms {
                chatrooms[room.guid] = room
            }
            // cache
            success(rooms)
        }) { (error: Error?) in
            failure(error)
        }
    }
    
    //MARK:- Messages
    static func observeNewMessages(roomId: String, limit: UInt, success: @escaping (Message1) -> (), failure: () -> ()) -> UInt{
        let ref = Database.database().reference()
        let chatRef = ref.child("messages").child(roomId)
        let refHandle = chatRef.queryLimited(toLast: limit).observe(DataEventType.childAdded, with: { (snapshot) in
            let postDict = snapshot.value as? NSDictionary ?? [:]
            let message = Message1(guid: snapshot.key, obj: postDict)
            success(message) 
        })
        return refHandle
    }
    
    static func observeNewMessagesAroundMe(limit: UInt, success: @escaping (Message1) -> (), failure: () -> ()) -> UInt{
        let ref = Database.database().reference()
        let chatRef = ref.child("aroundme").child(userGuid)
        let refHandle = chatRef.observe(DataEventType.childAdded, with: { (snapshot) in
            let postDict = snapshot.value as? NSDictionary ?? [:]
            let message = Message1(guid: snapshot.key, obj: postDict)
            success(message)
        })
        return refHandle
    }
    
    
    static func getMessagesAroundMe(limit: UInt, lastMsgId: String,
                                    success: @escaping ([Message1]) -> (), failure: @escaping (Error?) -> ()) {
        let ref = Database.database().reference()
        let chatRef = ref.child("aroundme").child(userGuid)
        chatRef.queryOrderedByKey().queryLimited(toLast: limit).queryEnding(atValue: lastMsgId).observeSingleEvent(of: DataEventType.value, with: { (snapshot: DataSnapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(postDict)
            let messages = Message1.messagesWithArray(dicts: postDict)
            success(messages)
        }) { (error: Error) in
            failure(error)
        }
    }
    
    static func getMessagesForRoom(roomId: String,
                                   limit: UInt,
                                   lastMsgId: String,
                                   success: @escaping ([Message1]) -> (), failure: @escaping (Error?) -> ()) {
        let ref = Database.database().reference()
        let chatRef = ref.child("messages").child(roomId)
        chatRef.queryOrderedByKey().queryLimited(toLast: limit).queryEnding(atValue: lastMsgId).observeSingleEvent(of: DataEventType.value, with: { (snapshot: DataSnapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(postDict)
            let messages = Message1.messagesWithArray(dicts: postDict)
            var sortedMessages = messages.sorted(by: { (msg1: Message1, msg2: Message1) -> Bool in
                return msg1.rawTimestamp > msg2.rawTimestamp
            })
            sortedMessages.removeFirst()
            success(sortedMessages)
        }) { (error: Error) in
            failure(error)
        }
    }
    
    static func sendMessage(message: Message1, room: ChatRoom1, success: @escaping () -> (), failure: @escaping () -> ()) {
        let ref = Database.database().reference()

        let newMsgKey = ref.child("messages").child(room.guid).childByAutoId().key
        
        var updateData =
            ["messages/\(room.guid!)/\(newMsgKey)" : message.toValue(),
            "chatrooms/\(room.guid!)/lastMessageTimestamp": ServerValue.timestamp()]
                as [String : Any]
        
        if ((message.message?.characters.count ?? 0) > 0) {
            updateData["chatrooms/\(room.guid!)/lastMessage"] = message.message!
        } else if ((message.attachment?.characters.count ?? 0) > 0) {
            updateData["chatrooms/\(room.guid!)/lastMessage"] = "\(message.name!) sent a picture"
        }
        
        print(updateData)
        
        ref.updateChildValues(updateData) { (error: Error?, DatabaseReference) in
            if (error != nil) {
                failure()
            } else {
                success()
            }
        }
        success()
    }
    
    //MARK:- User profile
    static func updateUserProfile(user: User1) {
        let ref = Database.database().reference()
        ref.child("users").child(user.guid!).updateChildValues(user.toValue())
    }
    
    static func registerIfNeeded(guid: String, user: FirebaseAuth.User, success: @escaping () -> (), failure: @escaping () -> ()) {
        userGuid = guid
        
        let value: [String: String] = [
            User1.KEY_DISPLAY_NAME: user.displayName!
//            User1.KEY_PROFILE_IMAGE: (user.photoURL?.absoluteString)!
        ]
        let ref = Database.database().reference()
        ref.child("users").child(guid).updateChildValues(value)
        
        getUserProfile(userGuid: guid, success: { (user: User1) in
            currentUser = user
            success()
        }) {
        }
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
    
    static func postUserLocation(userGuid: String, longitude: String, latitude: String, success: @escaping () -> (), failure: @escaping () -> ()) {
        let ref = Database.database().reference()
        let locVal : [String: String] = [
            "long": longitude,
            "lat" : latitude
        ]
        ref.child("users").child(userGuid).child("location").setValue(locVal)
        success()
    }
    
}
