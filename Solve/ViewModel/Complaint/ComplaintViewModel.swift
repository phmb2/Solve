//
//  ComplaintViewModel.swift
//  Solve
//
//  Created by Pedro Barbosa on 07/12/21.
//

import UIKit

struct ComplaintViewModel {
    // MARK: - Properties
    let complaint: Complaint
    let user: User
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        
        return formatter.string(from: complaint.timestamp, to: now) ?? ""
    }
    
    var userInfoText: NSAttributedString? {
        let title = NSMutableAttributedString(string: user.fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        title.append(NSAttributedString(string: " @\(user.username)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        title.append(NSAttributedString(string: " ∙ \(timestamp)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return title
    }
    
    var usernameText: String {
        return "@\(user.username)"
    }
    
    var bankText: String {
        return complaint.bank
    }
    
    var headerComplaintDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "pt-br")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: complaint.timestamp)
    }
    
    var retweetsAttributedString: NSAttributedString? {
        let complaintsText = complaint.complaintsCount == 1 ? " reclamação" : " reclamações"
        return attributedText(withValue: complaint.complaintsCount, text: complaintsText)
    }
    
    var likesAttributedString: NSAttributedString? {
        let likesText = complaint.likes == 1 ? " curtida" : " curtidas"
        return attributedText(withValue: complaint.likes, text: likesText)
    }
    
    var likeButtonTintColor: UIColor {
        return complaint.didLike ? .solveColor : .lightGray
    }
    
    var likeButtonImage: UIImage {
        let imageName = complaint.didLike ? "like_filled" : "like"
        return UIImage(named: imageName)!
    }
    
    var hideReplyLabel: Bool {
        return !complaint.isReply
    }
    
    var replyText: String? {
        guard let replyingToUsername = complaint.replyingTo else { return nil }
        return "→ replying to @\(replyingToUsername)"
    }
    
    // MARK: - Lifecycle
    init(complaint: Complaint) {
        self.complaint = complaint
        self.user = complaint.user
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedTitle.append(NSAttributedString(string: "\(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
    
    // MARK: - Helpers
    func size(forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = complaint.caption
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
