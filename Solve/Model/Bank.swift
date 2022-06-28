//
//  Bank.swift
//  Solve
//
//  Created by Pedro Barbosa on 24/12/21.
//

import Foundation

struct Bank: Equatable {
    let code: String
    let name: String
    let url: String
    
    init(code: String, name: String, url: String) {
        self.code = code
        self.name = name
        self.url = url
    }
    
    init() {
        self.code = ""
        self.name = ""
        self.url = ""
    }
}
