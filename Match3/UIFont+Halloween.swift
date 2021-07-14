//
//  UIFont+Halloween.swift
//  Match3
//
//  Created by Ricky Cancro on 7/14/21.
//

import UIKit

extension UIFont {
    
    static var customFontName: String {
        return "Kenney-Mini-Square"
    }
    
    static func customFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: self.customFontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
