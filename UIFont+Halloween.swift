//
//  UIFont+Halloween.swift
//  Match3
//
//  Created by Ricky Cancro on 7/14/21.
//

import UIKit

extension UIFont {
    static func customFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Kenney-Mini-Square", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
