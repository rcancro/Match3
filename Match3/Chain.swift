//
//  Chain.swift
//  Match3
//
//  Created by ricky cancro on 7/12/21.
//

import Foundation

class Chain: Hashable, CustomStringConvertible {
    var candies: [Candy] = []
    var score = 0
    var bonusTime: TimeInterval = 0
    
    enum ChainType: CustomStringConvertible {
        case horizontal
        case vertical
        
        var description: String {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func add(candy: Candy) {
        candies.append(candy)
    }
    
    func firstCandy() -> Candy {
        return candies.first!
    }
    
    func lastCandy() -> Candy {
        return candies.last!
    }
    
    var length: Int {
        return candies.count
    }
    
    var description: String {
        return "type:\(chainType) cookies:\(candies)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(candies.reduce (0) { $0.hashValue ^ $1.hashValue })
    }
    
    static func ==(lhs: Chain, rhs: Chain) -> Bool {
        return lhs.candies == rhs.candies
    }
}
