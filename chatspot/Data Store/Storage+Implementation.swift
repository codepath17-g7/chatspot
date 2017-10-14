//
//  Storage+Implementation.swift
//  chatspot
//
//  Created by Varun on 10/12/17.
//  Copyright © 2017 g7. All rights reserved.
//

import RealmSwift

struct Sorted {
    var key: String
    var ascending: Bool = true
}

// CRUD Implementation.

// Create
extension Storage {
    
    // Safe write. use this everywhere
    fileprivate func safeWrite(_ block: (() throws -> Void)) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        if realm.isInWriteTransaction {
            try block()
        } else {
            try realm.write(block)
        }
    }
    
    // Save an object to Realm
    func save(_ object: Object) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            realm.add(object)
        }
    }
}

// Read
extension Storage {
    
    // Fetch objects matching a filter/predicate
    func fetch<T: Object>(_ model: T.Type, predicate: NSPredicate? = nil, sorted: Sorted? = nil) -> [T] {
        var objects = self.realm?.objects(model)
        
        if let predicate = predicate {
            objects = objects?.filter(predicate)
        }
        
        if let sorted = sorted {
            objects = objects?.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
        }
        
        var accumulate: [T] = [T]()
        for object in objects! {
            accumulate.append(object)
        }
        
        return accumulate
    }
    
    func fetchResults<T: Object>(_ model: T.Type, predicate: NSPredicate? = nil, sorted: Sorted? = nil) -> Results<T> {
        var objects = self.realm?.objects(model)
        
        if let predicate = predicate {
            objects = objects?.filter(predicate)
        }
        
        if let sorted = sorted {
            objects = objects?.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
        }
        
        return objects!
    }
}

// Update
extension Storage {
    
    // Update an object.
    func update(block: @escaping () -> Void) throws {
        try self.safeWrite {
            block()
        }
    }
}

// Delete
extension Storage {
    
    // Delete an object
    func delete(_ object: Object) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            realm.delete(object)
        }
    }
    
    // Delte objects matching a filter/predicate
    func delete<T: Object>(_ model: T.Type, predicate: NSPredicate? = nil, completion: (() -> ())? = nil) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            let objectsToDelete = fetch(model)
            realm.delete(objectsToDelete)
            completion?()
        }
    }
    
    
    // Delete objects of a specific type
    func deleteAll<T : Object>(_ model: T.Type) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            let objects = realm.objects(model)
            
            for object in objects {
                realm.delete(object)
            }
        }
    }
    
    // Reset realm. Can be called for example when logging out
    func reset() throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            realm.deleteAll()
        }
    }
}
