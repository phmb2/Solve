//
//  Complaint.swift
//  Solve
//
//  Created by Pedro Barbosa on 22/11/21.
//

import Foundation

struct Complaint {
    let complaintId: String
    let caption: String
    var likes: Int
    let complaintsCount: Int
    var timestamp: Date!
    var user: User
    var bank: String
    var didLike = false
    var replyingTo: String?
    
    var isReply: Bool { return replyingTo != nil }
    
    init(user: User, complaintId: String, dictionary: [String: Any]) {
        self.user = user
        self.complaintId = complaintId
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.complaintsCount = dictionary["complaints"] as? Int ?? 0
        self.bank = dictionary["bank"] as? String ?? ""
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}
