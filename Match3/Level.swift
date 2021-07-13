//
//  GameLevel.swift
//  Match3
//
//  Created by ricky cancro on 7/11/21.
//

import SpriteKit

let numColumns = 7
let numRows = 11

class Level {
    private var candies = Array2D<Candy>(columns: numColumns, rows: numRows, initialValue: nil)
    
    
    func candy(atColumn column: Int, row: Int) -> Candy? {
        precondition(column >= 0 && column < numColumns)
        precondition(row >= 0 && row < numRows)
        return candies[column, row]
    }
    
    func shuffle() -> Set<Candy> {
        return createInitialCookies()
    }
    
    func removeCandy(_ candy: Candy) {
        candies[candy.column, candy.row] = nil
    }
    
    func removeCandies(_ candies: [Candy]) {
        candies.forEach { candy in
            self.removeCandy(candy)
        }
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
    
    private func createInitialCookies() -> Set<Candy> {
        var set: Set<Candy> = []
        
        for row in 0..<numRows {
            for column in 0..<numColumns {
                
                let candyType = CandyType.random()
                let candy = Candy(column: column, row: row, candyType: candyType)
                candies[column, row] = candy
                set.insert(candy)
            }
        }
        return set
    }
}
