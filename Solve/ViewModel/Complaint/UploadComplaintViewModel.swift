//
//  UploadComplaintViewModel.swift
//  Solve
//
//  Created by Pedro Barbosa on 22/11/21.
//

import UIKit

enum UploadComplaintConfiguration {
    case complaint
    case reply(Complaint)
}

struct UploadComplaintViewModel {
    // MARK: - Properties
    let actionButtonTitle: String
    let placeholderText: String
    var showReplyLabel: Bool
    var showBankContainerView: Bool
    var replyText: String?
    
    // MARK: - Lifecycle
    init(config: UploadComplaintConfiguration) {
        switch config {
        case .complaint:
            actionButtonTitle = "Reclamação"
            placeholderText = "O que está ocorrendo?"
            showReplyLabel = false
            showBankContainerView = false
        case .reply(let complaint):
            actionButtonTitle = "Responder"
            placeholderText = "Publique sua resposta"
            showReplyLabel = true
            showBankContainerView = true
            replyText = "Responder a @\(complaint.user.username)"
            
        }
    }
}
