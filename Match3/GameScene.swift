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
    
    let topBarYOffset: CGFloat = 70
    
    let tileWidth: CGFloat = 48.0
    let tileHeight: CGFloat = 48.0
    let tileSpacing: CGFloat = 8.0
    
    let gameLayer = SKNode()
    let candiesLayer = SKNode()
    
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    var swipeHandler: ((Swap) -> Void)?
    
    
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
            addSprite(for: candy)
        }
    }
    
    func addSprite(for candy: Candy) {
        let sprite = SKSpriteNode(imageNamed: candy.candyType.spriteName)
        sprite.size = CGSize(width: tileWidth, height: tileHeight)
        sprite.position = pointFor(column: candy.column, row: candy.row)
        candiesLayer.addChild(sprite)
        candy.sprite = sprite
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
                return (false, 0, 0)  // we are in the spacing
            }
            
            return (true, Int(point.x / (tileWidth + tileSpacing)), Int(point.y / (tileHeight + tileSpacing)))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
// MARK: - Touch events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        // Check if the user touched a candy
        let location = touch.location(in: candiesLayer)
        let (success, column, row) = convertPoint(location)
        if success {
            if let _ = level.candy(atColumn: column, row: row) {
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard swipeFromColumn != nil else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: candiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            var horizontalDelta = 0, verticalDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horizontalDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horizontalDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                verticalDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                verticalDelta = 1
            }
            
            if horizontalDelta != 0 || verticalDelta != 0 {
                trySwap(horizontalDelta: horizontalDelta, verticalDelta: verticalDelta)
                swipeFromColumn = nil
            }
        }
    }
    
    private func trySwap(horizontalDelta: Int, verticalDelta: Int) {
        
        let toColumn = swipeFromColumn! + horizontalDelta
        let toRow = swipeFromRow! + verticalDelta
        
        guard toColumn >= 0 && toColumn < numColumns else { return }
        guard toRow >= 0 && toRow < numRows else { return }
        
        if let toCandy = level.candy(atColumn: toColumn, row: toRow),
           let fromCandy = level.candy(atColumn: swipeFromColumn!, row: swipeFromRow!) {
            if let handler = swipeHandler {
                let swap = Swap(candyA: fromCandy, candyB: toCandy)
                handler(swap)
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
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
// MARK: - Game State
    
    func cleanUpMatch(_ candy: Candy) {
        candy.sprite?.removeFromParent()
        let replacement = level.replaceCandyWithRandomCandy(candy)
        addSprite(for: replacement)
        if let replacementSprite = replacement.sprite {
            replacementSprite.alpha = 0.0
            replacement.fadeIn()
        }
    }
    
    func gameOver() {
    }

// MARK: - Animations
    
    func animate(_ swap: Swap, completion: @escaping () -> Void) {
        let spriteA = swap.candyA.sprite!
        let spriteB = swap.candyB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> Void) {
        let spriteA = swap.candyA.sprite!
        let spriteB = swap.candyB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
    }
    
    func animateMatchedCandies(for chains: Set<Chain>, completion: @escaping () -> Void) {
        for chain in chains {
            animateScore(for: chain)
            for candy in chain.candies {
                if let sprite = candy.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                                   withKey: "removing")
                    }
                }
            }
        }
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animate(fallingCandies: [[Candy]], newCandies: [[Candy]], completion: @escaping () -> Void) {
        
        animateFallingCandies(in: fallingCandies) {
            
        }
        
        animateNewCandies(in: newCandies, completion: completion)
    }
    
    static let fallingCandyDuration: TimeInterval = 0.8
    
    func animateFallingCandies(in columns: [[Candy]], completion: @escaping () -> Void) {
        
        for array in columns {
            for (_, candy) in array.enumerated() {
                let newPosition = pointFor(column: candy.column, row: candy.row)
                let sprite = candy.sprite!   // sprite always exists at this point
                
                let moveAction = SKAction.move(to: newPosition, duration: GameScene.fallingCandyDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
                sprite.run(moveAction)
            }
        }
        
        run(SKAction.wait(forDuration: GameScene.fallingCandyDuration), completion: completion)
    }
    
    func animateNewCandies(in columns: [[Candy]], completion: @escaping () -> Void) {
        
        for array in columns {
            let startRow = array[0].row + 1
            
            for (_, candy) in array.enumerated() {
                
                let sprite = SKSpriteNode(imageNamed: candy.candyType.spriteName)
                sprite.size = CGSize(width: tileWidth, height: tileHeight)
                sprite.position = pointFor(column: candy.column, row: startRow)
                candiesLayer.addChild(sprite)
                candy.sprite = sprite
                
                let newPosition = pointFor(column: candy.column, row: candy.row)
                let moveAction = SKAction.move(to: newPosition, duration: GameScene.fallingCandyDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
                sprite.alpha = 0
                sprite.run(
                    SKAction.sequence([
                        SKAction.group([
                                        SKAction.fadeIn(withDuration: 0.05),
                                        moveAction])
                    ]))
            }
        }
        
        run(SKAction.wait(forDuration: GameScene.fallingCandyDuration), completion: completion)
    }

    func animateScore(for chain: Chain) {
        // Figure out what the midpoint of the chain is.
        let firstSprite = chain.firstCandy().sprite!
        let lastSprite = chain.lastCandy().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        let scoreLabel = SKLabelNode(fontNamed: "Kenney-Bold")
        scoreLabel.fontSize = 16
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        scoreLabel.text = "\(chain.score)"
        scoreLabel.fontColor = chain.firstCandy().candyType.associatedColor
        scoreLabel.xScale = 0
        scoreLabel.yScale = 0
        candiesLayer.addChild(scoreLabel)
        
        let scaleAction = SKAction.scale(to: 1.5, duration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0)
        let fadeAction = SKAction.fadeAlpha(to: 0.0, duration: 1)
        let groupAction = SKAction.group([scaleAction, fadeAction])
        scoreLabel.run(SKAction.sequence([groupAction, SKAction.removeFromParent()]))
    }

// MARK: - Misc
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

