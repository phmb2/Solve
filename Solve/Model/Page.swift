//
//  TutorialPage.swift
//  Solve
//
//  Created by Pedro Barbosa on 15/11/21.
//

import UIKit

struct TutorialPage {
    var image: UIImage?
    var description: String
}

enum Page: Int, CaseIterable {
    case pageOne
    case pageTwo
    case pageThree

    var index: Int {
        rawValue
    }

    var tutorialPage: TutorialPage {
        switch self {
        case .pageOne:
            return TutorialPage(image: UIImage(named: "tutorial_page_one"), description: "Olá! Bem vindo ao Solve! Você pode relatar seu problema com sua instituição financeira aqui.")
        case .pageTwo:
            return TutorialPage(image: UIImage(named: "tutorial_page_two"), description: "No Solve você pode avaliar as reclamações de outros usuários.")
        case .pageThree:
            return TutorialPage(image: UIImage(named: "tutorial_page_three"), description: "Solve lhe ajudará a avaliar como as instituições financeiras atendem seus clientes.")
        }
    }
}
