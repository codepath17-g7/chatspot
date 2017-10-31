//
//  Date+Ago.swift
//  chatspot
//
//  Created by Varun on 10/31/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation

extension Date {
    
    func ago(pastDate: Date?)-> String {
        
        if let pastDate = pastDate {
            let components = Calendar.current.dateComponents([.day, .hour, .minute], from: pastDate, to: self)
            
            let day = components.day ?? 0
            let hour = components.hour ?? 0
            let minutes = components.minute ?? 0
            
            if (day > 0) {
                return "\(day)d"
            } else if (hour > 0) {
                return "\(hour)h"
            } else if (minutes > 0) {
                return "\(minutes)m"
            }
            
            return "Now"
            
        } else {
            
            return ""
        }
    }
    
}
