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
    
    // User operations ---------------
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
    
    func getUsers(_ predicate: NSPredicate) {
        
    }
    
    func getAllUsers() {
        
    }
    
    func updateUser(_ user: User) {
        
    }
    
    func removeUser(_ user: User) -> Bool {
        do {
            try delete(user)
            return true
        } catch {
            return false
        }
        
    }
    
    func removeUsers(_ predicte: NSPredicate) {
        
    }
    
    // Message operations ---------------
    func saveMessage(_ message: Message) {
        
    }
    
    func getMessages(_ predicate: NSPredicate) {
        
    }
    
    func removeMessage(_ message: Message) -> Bool {
        do {
            try delete(message)
            return true
        } catch {
            return false
        }
        
    }
    
    func removeMessages(_ predicate: NSPredicate) {
        
    }
    
}
