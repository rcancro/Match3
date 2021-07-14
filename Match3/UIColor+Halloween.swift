//
//  UIColor+Halloween.swift
//  Match3
//
//  Created by Ricky Cancro on 7/14/21.
//

import UIKit

extension UIColor {

    static func color(fromHexValue hexValue: Int, alpha: CGFloat = 1.0 ) -> UIColor {
        return UIColor(red: CGFloat(((hexValue & 0xFF0000) >> 16))/255.0,
                       green: CGFloat(((hexValue & 0xFF00) >> 8))/255.0,
                       blue: CGFloat((hexValue & 0xFF))/255.0, alpha: alpha)
    }
    
    static var halloweenPurple:  UIColor {
        return UIColor.color(fromHexValue: 0xC62FAE)
    }
    
    static var halloweenYellowGreen:  UIColor {
        return UIColor.color(fromHexValue: 0xC6FD34)
    }

    static var halloweenRed:  UIColor {
        return UIColor.color(fromHexValue: 0xFC2820)
    }
    
    
}
