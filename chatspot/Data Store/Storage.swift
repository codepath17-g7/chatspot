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
}
