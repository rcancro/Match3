//
//  GameScene.swift
//  Match3
//
//  Created by ricky cancro on 7/11/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var level: Level!
    
    let tileWidth: CGFloat = 48.0
    let tileHeight: CGFloat = 48.0
    let tileSpacing: CGFloat = 8.0
    
    let gameLayer = SKNode()
    let candiesLayer = SKNode()
    
    var currentChain = [Candy]()
    var lastElementInChain: Candy? {
        return currentChain.last
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        addChild(gameLayer)
        
        let allTilesWidth = tileWidth * CGFloat(numColumns)
        let allSpacingWidth = tileSpacing * CGFloat(numColumns-1)
        let layerPosition = CGPoint(
            x: (size.width - (allTilesWidth + allSpacingWidth))/2.0,
            y: 60)

        candiesLayer.position = layerPosition
        gameLayer.addChild(candiesLayer)
    }
    
    func addSprites(for candies: Set<Candy>) {
        for candy in candies {
            let sprite = SKSpriteNode(imageNamed: candy.candyType.spriteName)
            sprite.size = CGSize(width: tileWidth, height: tileHeight)
            sprite.position = pointFor(column: candy.column, row: candy.row)
            candiesLayer.addChild(sprite)
            candy.sprite = sprite
        }
    }
    
    private func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: (CGFloat(column) * tileWidth) + (tileWidth / 2) + (CGFloat(column) * tileSpacing),
            y: (CGFloat(row) * tileHeight) + (tileHeight / 2) + (CGFloat(row) * tileSpacing))
    }

    private func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        let totalWidth = (CGFloat(numColumns) * tileWidth) + (CGFloat(numColumns - 1) * tileSpacing)
        let totalHeight = (CGFloat(numRows) * tileHeight) + (CGFloat(numRows - 1) * tileSpacing)

        if point.x >= 0 && point.x < totalWidth &&
            point.y >= 0 && point.y < totalHeight {
            
            let remainderX = point.x.truncatingRemainder(dividingBy: tileWidth + tileSpacing)
            let remainderY = point.y.truncatingRemainder(dividingBy: tileHeight + tileSpacing)
            if remainderX > tileWidth || remainderY > tileHeight{
                // we are in the spacing
                return (false, 0, 0)  // invalid location
            }

            return (true, Int(point.x / (tileWidth + tileSpacing)), Int(point.y / (tileHeight + tileSpacing)))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: candiesLayer)
        let (success, column, row) = convertPoint(location)
        if success, let candy = level.candy(atColumn: column, row: row) {
            currentChain.append(candy)
            candy.highlight(true, atChainPosition: currentChain.count)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: candiesLayer)
        let (success, column, row) = convertPoint(location)
        if success, let candy = level.candy(atColumn: column, row: row) {
            if currentChain.contains(candy), candy != lastElementInChain {
                // do we break the chain here? we are crossing the streams
            } else if !currentChain.contains(candy) && candy.isValidForChain(currentChain){
                currentChain.append(candy)
                candy.highlight(true, atChainPosition: currentChain.count)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches()
    }
    
    func endTouches() {
        // check to see if we have a chain.
        if currentChain.count > 0 {
            var validChain = currentChain.count >= 3
            if validChain {
                let candyType = currentChain.randomElement()!.candyType
                currentChain.forEach { candy in
                    validChain = validChain && candy.candyType == candyType
                }
            }
            
            if validChain {
                // we matched, let's play some crazy animation
            } else {
                // no match, lets deselect
                for (index, item) in currentChain.reversed().enumerated() {
                    item.highlight(false, atChainPosition: currentChain.count - index - 1)
                }
                currentChain = [Candy]()
            }
            
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
