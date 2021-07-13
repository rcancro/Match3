//
//  GameLevel.swift
//  Match3
//
//  Created by ricky cancro on 7/11/21.
//

import SpriteKit

let numColumns = 6
let numRows = 10

class Level {
    private var candies = Array2D<Candy>(columns: numColumns, rows: numRows, initialValue: nil)
    private var possibleSwaps: Set<Swap> = []
    private var comboMultiplier = 1
    let baseLevelTime: TimeInterval = 30
    let shufflePenalityTime: TimeInterval = -10
    private var comboTimeMultiplier = 1.0
    
    func candy(atColumn column: Int, row: Int) -> Candy? {
        precondition(column >= 0 && column < numColumns)
        precondition(row >= 0 && row < numRows)
        return candies[column, row]
    }
    
    func shuffle() -> Set<Candy> {
        var set: Set<Candy>
        repeat {
            set = createInitialCookies()
            detectPossibleSwaps()
        } while possibleSwaps.count == 0
        
        return set
    }
    
    private func hasChain(atColumn column: Int, row: Int) -> Bool {
        let candyType = candies[column, row]!.candyType
        
        // Horizontal chain check
        var horizontalLength = 1
        
        // Left
        var i = column - 1
        while i >= 0 && candies[i, row]?.candyType == candyType {
            i -= 1
            horizontalLength += 1
        }
        
        // Right
        i = column + 1
        while i < numColumns && candies[i, row]?.candyType == candyType {
            i += 1
            horizontalLength += 1
        }
        if horizontalLength >= 3 { return true }
        
        // Vertical chain check
        var verticalLength = 1
        
        // Down
        i = row - 1
        while i >= 0 && candies[column, i]?.candyType == candyType {
            i -= 1
            verticalLength += 1
        }
        
        // Up
        i = row + 1
        while i < numRows && candies[column, i]?.candyType == candyType {
            i += 1
            verticalLength += 1
        }
        return verticalLength >= 3
    }
    
    func detectPossibleSwaps() {
        var set: Set<Swap> = []
        
        for row in 0..<numRows {
            for column in 0..<numColumns {
                if let candy = candies[column, row] {
                    if column < numColumns - 1,
                       let other = candies[column + 1, row] {
                        // Swap them
                        candies[column, row] = other
                        candies[column + 1, row] = candy
                        
                        // Is either cookie now part of a chain?
                        if hasChain(atColumn: column + 1, row: row) ||
                            hasChain(atColumn: column, row: row) {
                            set.insert(Swap(candyA: candy, candyB: other))
                        }
                        
                        // Swap them back
                        candies[column, row] = candy
                        candies[column + 1, row] = other
                    }
                    
                    if row < numRows - 1,
                       let other = candies[column, row + 1] {
                        candies[column, row] = other
                        candies[column, row + 1] = candy
                        
                        // Is either cookie now part of a chain?
                        if hasChain(atColumn: column, row: row + 1) ||
                            hasChain(atColumn: column, row: row) {
                            set.insert(Swap(candyA: candy, candyB: other))
                        }
                        
                        // Swap them back
                        candies[column, row] = candy
                        candies[column, row + 1] = other
                    }
                }
                else if column == numColumns - 1, let candy = candies[column, row] {
                    if row < numRows - 1,
                       let other = candies[column, row + 1] {
                        candies[column, row] = other
                        candies[column, row + 1] = candy
                        
                        // Is either cookie now part of a chain?
                        if hasChain(atColumn: column, row: row + 1) ||
                            hasChain(atColumn: column, row: row) {
                            set.insert(Swap(candyA: candy, candyB: other))
                        }
                        
                        // Swap them back
                        candies[column, row] = candy
                        candies[column, row + 1] = other
                    }
                    
                }
            }
        }
        
        possibleSwaps = set
    }
    
    private func detectHorizontalMatches() -> Set<Chain> {
        // 1
        var set: Set<Chain> = []
        // 2
        for row in 0..<numRows {
            var column = 0
            while column < numColumns-2 {
                // 3
                if let candy = candies[column, row] {
                    let matchType = candy.candyType
                    // 4
                    if candies[column + 1, row]?.candyType == matchType &&
                        candies[column + 2, row]?.candyType == matchType {
                        // 5
                        let chain = Chain(chainType: .horizontal)
                        repeat {
                            chain.add(candy: candies[column, row]!)
                            column += 1
                        } while column < numColumns && candies[column, row]?.candyType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                // 6
                column += 1
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set: Set<Chain> = []
        
        for column in 0..<numColumns {
            var row = 0
            while row < numRows-2 {
                if let candy = candies[column, row] {
                    let matchType = candy.candyType
                    
                    if candies[column, row + 1]?.candyType == matchType &&
                        candies[column, row + 2]?.candyType == matchType {
                        let chain = Chain(chainType: .vertical)
                        repeat {
                            chain.add(candy: candies[column, row]!)
                            row += 1
                        } while row < numRows && candies[column, row]?.candyType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                row += 1
            }
        }
        return set
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 0
        comboTimeMultiplier = 1.0
    }
    
    private func calculateScores(for chains: Set<Chain>) {
        for chain in chains {
            let baseScore = chain.firstCandy().candyType.baseScore
            let scoreChainLength = chain.length - 2
            // be fancy and shift for 2^comboMultiplier because pow() keeps complaing to me
            chain.score = baseScore * scoreChainLength * scoreChainLength * (2 << comboMultiplier)
            // cap the multiplier
            comboMultiplier = min(comboMultiplier + 1, 7)
        }
    }
    
    private func calculateBonusTime(for  chains: Set<Chain>) {
        for chain in chains {
            let scoreChainLength = chain.length - 2
            chain.bonusTime = ceil(Double(scoreChainLength) * 1.1 * comboTimeMultiplier)
            comboTimeMultiplier = comboTimeMultiplier * 1.5
        }
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeCandies(in: horizontalChains)
        removeCandies(in: verticalChains)
        
        calculateScores(for: horizontalChains)
        calculateScores(for: verticalChains)
        
        calculateBonusTime(for: horizontalChains)
        calculateBonusTime(for: verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    private func removeCandies(in chains: Set<Chain>) {
        for chain in chains {
            for candy in chain.candies {
                candies[candy.column, candy.row] = nil
            }
        }
    }
    
    func isPossibleSwap(_ swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    func topUpCookies() -> [[Candy]] {
        var columns: [[Candy]] = []
        var candyType: CandyType = .unknown
        
        for column in 0..<numColumns {
            var array: [Candy] = []
            
            var row = numRows - 1
            while row >= 0 && candies[column, row] == nil {
                var newCandyType: CandyType
                repeat {
                    newCandyType = CandyType.random()
                } while newCandyType == candyType
                candyType = newCandyType
                
                let candy = Candy(column: column, row: row, candyType: candyType)
                candies[column, row] = candy
                array.append(candy)
                
                row -= 1
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func fillHoles() -> [[Candy]] {
        var columns: [[Candy]] = []
        for column in 0..<numColumns {
            var array: [Candy] = []
            for row in 0..<numRows {
                if candies[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<numRows {
                        if let candy = candies[column, lookup] {
                            candies[column, lookup] = nil
                            candies[column, row] = candy
                            candy.row = row
                            array.append(candy)
                            break
                        }
                    }
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    
    func removeCandy(_ candy: Candy) {
        candies[candy.column, candy.row] = nil
    }
    
    func replaceCandyWithRandomCandy(_ candy: Candy) -> Candy {
        let newCandy = Candy(column: candy.column, row: candy.row, candyType: CandyType.random())
        candies[candy.column, candy.row] = newCandy
        return newCandy
    }
    
    func chain(atColumn column: Int, row: Int) -> [Candy]? {
        return candies.chain(atColumn: column, row: row)
    }
    
    func levelStillHasChains() -> Bool {
        for row in 0..<numRows {
            for column in 0..<numColumns {
                if candies.chain(atColumn: column, row: row) != nil {
                    return true
                }
            }
        }
        return false
    }
    
    func performSwap(_ swap: Swap) {
        let columnA = swap.candyA.column
        let rowA = swap.candyA.row
        let columnB = swap.candyB.column
        let rowB = swap.candyB.row
        
        candies[columnA, rowA] = swap.candyB
        swap.candyB.column = columnA
        swap.candyB.row = rowA
        
        candies[columnB, rowB] = swap.candyA
        swap.candyA.column = columnB
        swap.candyA.row = rowB
    }
    
    private func createInitialCookies() -> Set<Candy> {
        var set: Set<Candy> = []
        
        for row in 0..<numRows {
            for column in 0..<numColumns {
                
                var candyType: CandyType
                repeat {
                    candyType = CandyType.random()
                } while (column >= 2 &&
                            candies[column - 1, row]?.candyType == candyType &&
                            candies[column - 2, row]?.candyType == candyType)
                    || (row >= 2 &&
                            candies[column, row - 1]?.candyType == candyType &&
                            candies[column, row - 2]?.candyType == candyType)
                
                let candy = Candy(column: column, row: row, candyType: candyType)
                candies[column, row] = candy
                set.insert(candy)
            }
        }
        return set
    }
}
