//
//  Candy.swift
//  Match3
//
//  Created by ricky cancro on 7/11/21.
//

import SpriteKit

// MARK: - CookieType
enum CandyType: Int, CaseIterable {
  case unknown = 0,
       smartie,
       lollipop,
       MAndM,
       candyCorn,
       tootsie,
       hardCandy
    
    var spriteName: String {
      let spriteNames = [
        "smarties",
        "orange-pop",
        "mm-red",
        "candy-corn",
        "tootsie-roll",
        "pink-candy"]

      return spriteNames[rawValue - 1]
    }

    var highlightedSpriteName: String {
      return spriteName + "-highlighted"
    }
    
    static func random() -> CandyType {
        return CandyType(rawValue: Int(arc4random_uniform(UInt32(CandyType.allCases.count - 1)) + 1))!
    }
}

// MARK: - Cookie
class Candy: CustomStringConvertible, Hashable {
  
    func hash(into hasher: inout Hasher) {
        hasher.combine(row * 10 + column)
    }
    
    static func ==(lhs: Candy, rhs: Candy) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
        
    }
    
  var description: String {
    return "type:\(candyType) square:(\(column),\(row))"
  }
  
  var column: Int
  var row: Int
  let candyType: CandyType
  var sprite: SKSpriteNode?
  
  init(column: Int, row: Int, candyType: CandyType) {
    self.column = column
    self.row = row
    self.candyType = candyType
  }
}
