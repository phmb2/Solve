//
//  EditProfileViewModel.swift
//  Solve
//
//  Created by Pedro Barbosa on 08/12/21.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
            case .fullname: return "Nome"
            case .username: return "Login"
            case .bio: return ""
        }
    }
}

struct EditProfileViewModel {
    // MARK: - Properties
    private let user: User
    let option: EditProfileOptions
    
    // MARK: - Lifecycle
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
    
    var optionLabel: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
            case .fullname: return user.fullname
            case .username: return user.username
            case .bio: return user.bio
        }
    }
    
    var hideTextField: Bool {
        return option == .bio
    }
    
    var hideTextView: Bool {
        return option != .bio
    }
    
    var hidePlaceholderLabel: Bool {
        return user.bio != nil
    }
}
