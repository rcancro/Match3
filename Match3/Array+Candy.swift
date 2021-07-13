//
//  Array+Candy.swift
//  Match3
//
//  Created by Ricky Cancro on 7/12/21.
//

import Foundation
import SpriteKit

extension Array where Element == Candy {
    
    func isValidChain() -> Bool {
        var validChain = count >= 3
        if validChain {
            let candyType = randomElement()!.candyType
            forEach { candy in
                validChain = validChain && candy.candyType == candyType
            }
        }
        return validChain
    }
    
    func highlight() {
        for (index, item) in reversed().enumerated() {
            item.highlight(true, atChainPosition: index)
        }
    }
    
    func deselectChain() {
        for (index, item) in reversed().enumerated() {
            item.highlight(false, atChainPosition: count - index - 1)
        }
    }
    
    func matchChain(completion: @escaping ([Candy]) -> Void) {

        for (_, item) in reversed().enumerated() {
            item.matchAnimation()
        }
        
        if let anyNode = randomElement() {
            anyNode.sprite?.run(.wait(forDuration: Candy.matchDuration)) {
                completion(self)
            }
        }
    }
}
