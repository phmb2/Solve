//
//  ActionSheetViewModel.swift
//  Solve
//
//  Created by Pedro Barbosa on 25/11/21.
//

import Foundation

enum ActionSheetOptions {
    case follow(User)
    case unfollow(User)
    case report
    case delete
    
    var description: String {
        switch self {
            case .follow(let user):
                return "Follow @\(user.username)"
            case .unfollow(let user):
                return "Unfollow @\(user.username)"
            case .report:
                return "Reportar reclamação"
            case .delete:
                return "Deletar reclamação"
        }
    }
}

struct ActionSheetViewModel {
    private let user: User
    
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        
        results.append(.report)
        
        return results
    }
    
    init(user: User) {
        self.user = user
    }
}
