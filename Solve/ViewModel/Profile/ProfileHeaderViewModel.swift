//
//  ProfileHeaderViewModel.swift
//  Solve
//
//  Created by Pedro Barbosa on 08/12/21.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case complaints
    case replies
    case likes
    
    var description: String {
        switch self {
            case .complaints: return "Reclamações"
            case .replies: return "Respostas"
            case .likes: return "Curtidas"
        }
    }
}

struct ProfileHeaderViewModel {
    // MARK: - Properties
    private let user: User
    let usernameText: String
    
    var followingText: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: " seguindo")
    }
    
    var followersText: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: " seguidores")
    }
    
    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Editar Perfil"
        }
        
        if !user.isFollowed && !user.isCurrentUser {
            return "Seguir"
        }
        
        if user.isFollowed {
            return "Seguindo"
        }
        
        return "Carregando"
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        self.usernameText = "@" + user.username
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: "\(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
}
