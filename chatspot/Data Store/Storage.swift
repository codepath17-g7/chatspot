//
//  Storage.swift
//  chatspot
//
//  Created by Varun on 10/12/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import RealmSwift

class Storage {
    
    // singleton access
    static let instance = Storage()
    
    var realm: Realm?
    
    private init() {
        self.realm = try? Realm()
    }
    
    // ChatRoom operations ---------------
    /**
     Create a chat room.
     
     - parameter chatRoom: Chatroom to be created
     
     - returns: true if creation was successful
     */
    func createChatRoom(_ chatRoom: ChatRoom)-> Bool {
        do {
            try save(chatRoom)
            return true
        } catch {
            return false
        }
    }
    
    /**
     Get an array of chatrooms!
     
     - returns: An `Array` of `ChatRoom`
     */
    func getAllChatRooms() -> [ChatRoom] {
        return fetch(ChatRoom.self)
    }
    
    
    /**
     Get all chatrooms in a live result format
     
     - returns: A live result object that autoupdates itself when data is added, updated, removed
     */
    func getAllChatRooms() -> Results<ChatRoom> {
        return fetchResults(ChatRoom.self)
    }
    
    /**
     Remove a chat room.
     
     - parameter chatRoom: Chatroom to be removed
     
     - returns: true if removal was successful
     */
    func removeChatRoom(_ chatRoom: ChatRoom) -> Bool {
        do {
            try delete(chatRoom)
            return true
        } catch {
            return false
        }
    }
    
    /**
     Add an user to chatroom
     
     - parameter user: user to be added
     
     - parameter chatRoom: chat room to add the user to
     
     - returns: true if user was added successfully
     */
    func addUserToChatRoom(_ user: User, chatRoom: ChatRoom) -> Bool {
        do {
            try update { chatRoom.users.append(user) }
            return true
        } catch {
            return false
        }
    }
    
    // User operations ---------------
    /**
     Save user.
     
     - parameter user: User to be saved
     
     - returns: true if save was successful
     */
    func saveUser(_ user: User) -> Bool {
        do {
            try save(user)
            return true
        } catch {
            return false
        }
    }
    
    func getLoggedInUser() {
        // TODO: figure out how to identify the logged in user
    }
    
    /**
     Get an array of users filtered by the predicate
     
     - parameter predicate: predicate to apply to filter users
     
     - returns: An `Array` of `ChatRoom`
     */
    func getUsers(_ predicate: NSPredicate) -> [User] {
        return fetch(User.self, predicate: predicate)
    }
    
    /**
     Get users in a live result format
     
     - parameter predicate: predicate to apply to filter users
     
     - returns: A live result object that autoupdates itself when data is added, updated, removed
     */
    func getUsers(_ predicate: NSPredicate) -> Results<User> {
        return fetchResults(User.self, predicate: predicate)
    }
    
    /**
     Update user
     
     - parameter block: block that updates the user
     
     - returns: true if update was successful
     */
    func updateUser(block: @escaping () -> ()) -> Bool {
        do {
            try update { block() }
            return true
        } catch {
            return false
        }
    }
    
    /**
     Remove a user.
     
     - parameter user: User to be removed
     
     - returns: true if removal was successful
     */
    func removeUser(_ user: User) -> Bool {
        do {
            try delete(user)
            return true
        } catch {
            return false
        }
    }
    
    // Message operations ---------------
    /**
     Save a message from user in a chatroom
     
     - parameter message: Message to be saved
     
     - parameter user: User who composed the message
     
     - parameter chatRoom: Chat room where the message was sent
     
     - returns: true if save was successful
     */
    func saveMessage(_ message: Message, from user: User, chatRoom: ChatRoom) -> Bool {
        message.user = user
        message.chatRoom = chatRoom
        do {
            try save(message)
            return true
        } catch {
            return false
        }
    }
    
    /**
     Get an array of messages
     
     - parameter predicate: predicate to apply to filter messages
     
     - returns: An `Array` of `Message`
     */
    func getMessages(_ predicate: NSPredicate) -> [Message] {
        return fetch(Message.self, predicate: predicate)
    }
    
    /**
     Get messages in a live result format
     
     - parameter predicate: predicate to apply to filter messages
     
     - returns: A live result object that autoupdates itself when data is added, updated, removed
     */
    func getMessages(_ predicate: NSPredicate) -> Results<Message> {
        return fetchResults(Message.self, predicate: predicate)
    }
    
    /**
     Remove a message.
     
     - parameter message: Message to be removed
     
     - returns: true if removal was successful
     */
    func removeMessage(_ message: Message) -> Bool {
        do {
            try delete(message)
            return true
        } catch {
            return false
        }
        
    }
    
    /**
     Remove messages matching a filter.
     
     - parameter predicate: filter the messages to be deleted
     
     - returns: true if removal was successful
     */
    func removeMessages(_ predicate: NSPredicate) -> Bool {
        do {
            try delete(Message.self, predicate: predicate)
            return true
        } catch {
            return false
        }
    }
}
