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
    
    // ChatRoom operations
    func createChatRoom(_ chatRoom: ChatRoom) {
        
    }
    
    func getAllChatRooms() {
        
    }
    
    func removeChatRoom(_ chatRoom: ChatRoom) {
        
    }
    
    // User operations
    func saveUser(_ user: User) {
        
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
    
    func removeUser(_ user: User) {
        
    }
    
    func removeUsers(_ predicte: NSPredicate) {
        
    }
    
    // Message operations
    func saveMessage(_ message: Message) {
        
    }
    
    func getMessages(_ predicate: NSPredicate) {
        
    }
    
    func removeMessage(_ message: Message) {
        
    }
    
    func removeMessages(_ predicate: NSPredicate) {
        
    }
    
}
