//
//  UIColor+Extension.swift
//  Solve
//
//  Created by Pedro Barbosa on 18/12/21.
//

import UIKit

// MARK: - UIColor
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let solveColor = UIColor.rgb(red: 0, green: 71, blue: 171)
}
