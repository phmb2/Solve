//
//  Notification.swift
//  Solve
//
//  Created by Pedro Barbosa on 22/11/21.
//

import Foundation

enum NotificationType: Int {
    case follow
    case like
    case reply
    case repost
    case mention
}

struct Notification {
    var complaintId: String?
    var timestamp: Date!
    var user: User
    var type: NotificationType!
    
    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
        
        if let complaintId = dictionary["complaintId"] as? String {
            self.complaintId = complaintId
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
