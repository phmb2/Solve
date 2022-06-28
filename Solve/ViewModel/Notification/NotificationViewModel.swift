//
//  NotificationViewModel.swift
//  Solve
//
//  Created by Pedro Barbosa on 22/11/21.
//

import UIKit

struct NotificationViewModel {
    // MARK: - Properties
    private let notification: Notification
    private let type: NotificationType
    private let user: User
    
    var timestamp: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        
        return formatter.string(from: notification.timestamp, to: now) ?? ""
    }
    
    var notificationMessage: String {
        switch type {
            case .follow: return " começou a seguir você"
            case .like: return " curtiu sua reclamação"
            case .reply: return " respondeu sua reclamação"
            case .repost: return " publicou sua reclamação"
            case .mention: return " mencionou você em uma reclamação"
        }
    }
    
    var notificationText: NSAttributedString? {
        guard let timestamp = timestamp else { return nil }
        
        let attributedText = NSMutableAttributedString(string: user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: " \(timestamp)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        return attributedText
    }
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var followButtonText: String {
        return user.isFollowed ? "Seguindo" : "Seguir"
    }
    
    var hideFollowButton: Bool {
        return type != .follow
    }
    
    // MARK: - Lifecycle
    init(notification: Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
}
