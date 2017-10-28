//
//  String+Util.swift
//  chatspot
//
//  Created by Varun on 10/27/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation

extension String {
    
    /// Check if empty after removing whitespace and new line characters
    var isBlank: Bool {
        return self.isEmpty || self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
