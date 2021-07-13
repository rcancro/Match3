//
//  Swap.swift
//  Match3
//
//  Created by ricky cancro on 7/12/21.
//

import Foundation

struct Swap: CustomStringConvertible, Hashable {
    let candyA: Candy
    let candyB: Candy
    
    init(candyA: Candy, candyB: Candy) {
        self.candyA = candyA
        self.candyB = candyB
    }
    
    var description: String {
        return "swap \(candyA) with \(candyB)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(candyA.hashValue ^ candyB.hashValue)
    }
    
    static func ==(lhs: Swap, rhs: Swap) -> Bool {
        return (lhs.candyA == rhs.candyA && lhs.candyB == rhs.candyB) ||
            (lhs.candyB == rhs.candyA && lhs.candyA == rhs.candyB)
    }
}
