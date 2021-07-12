//
//  Array2D+Candy.swift
//  Match3
//
//  Created by Ricky Cancro on 7/12/21.
//

import Foundation

extension Array2D where T == Candy {
    
    func chain(atColumn column: Int, row: Int) -> [Candy]? {
        
        if let candy = self[column, row] {
            var currentChain = [Candy]()
            var candies = Set<Candy>()
            currentChain.append(candy)
            candies.insert(candy)
            
            let chain = findChain(withCandy: candy, currentChain: &currentChain, currentCandies: &candies)
            if chain.isValidChain() {
                return chain
            }
        }
        return nil
        
    }
    
    private func findChain(withCandy candy:Candy, currentChain: inout [Candy], currentCandies: inout Set<Candy>) -> [Candy] {
        
        var nextCandy: Candy?
        if let candyN = self[candy.column, candy.row + 1], candyN.candyType == candy.candyType, !currentCandies.contains(candyN) {
            nextCandy = candyN
        } else if let candyS = self[candy.column, candy.row - 1], candyS.candyType == candy.candyType, !currentCandies.contains(candyS) {
            nextCandy = candyS
        } else if let candyW = self[candy.column - 1, candy.row], candyW.candyType == candy.candyType, !currentCandies.contains(candyW) {
            nextCandy = candyW
        } else if let candyE = self[candy.column + 1, candy.row], candyE.candyType == candy.candyType, !currentCandies.contains(candyE) {
            nextCandy = candyE
        } else if let candyNW = self[candy.column - 1, candy.row + 1], candyNW.candyType == candy.candyType, !currentCandies.contains(candyNW) {
            nextCandy = candyNW
        } else if let candySW = self[candy.column - 1, candy.row - 1], candySW.candyType == candy.candyType, !currentCandies.contains(candySW) {
            nextCandy = candySW
        } else if let candyNE = self[candy.column + 1, candy.row + 1], candyNE.candyType == candy.candyType, !currentCandies.contains(candyNE) {
            nextCandy = candyNE
        } else if let candySE = self[candy.column + 1, candy.row - 1], candySE.candyType == candy.candyType, !currentCandies.contains(candySE) {
            nextCandy = candySE
        }
        
        if let nextCandy = nextCandy {
            currentChain.append(nextCandy)
            currentCandies.insert(nextCandy)
            return findChain(withCandy: nextCandy, currentChain: &currentChain, currentCandies: &currentCandies)
        } else {
            return currentChain
        }
    }
    
}
