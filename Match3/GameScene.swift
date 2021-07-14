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
    
    let tileWidth: CGFloat = 44.0
    let tileHeight: CGFloat = 44.0
    let tileSpacing: CGFloat = 8.0
    
    let gameLayer = SKNode()
    let candiesLayer = SKNode()
    var footerHeight: CGFloat {
        return footerSprite.size.height
    }
    
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    var swipeHandler: ((Swap) -> Void)?
    
    let backgroundSprite = SKSpriteNode(imageNamed: "background")
    let footerSprite = SKSpriteNode(imageNamed: "footer")
    
    override init(size: CGSize) {
        super.init(size: size)
        addChild(gameLayer)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.position = .zero
        backgroundSprite.zPosition = -1
        
        footerSprite.centerRect = CGRect(x: 0.3, y: 0, width: 0.1, height: 0)
        footerSprite.anchorPoint = .zero
        footerSprite.position = .zero
        footerSprite.zPosition = 0
        footerSprite.size = CGSize(width: view.frame.width, height: footerSprite.size.height)
        
        let backgroundWidth = floor(((view.frame.height - footerSprite.size.height) * backgroundSprite.size.width)/backgroundSprite.size.height)
        let backgroundHeight = floor((backgroundSprite.size.height * view.frame.width)/backgroundSprite.size.width)
        let desiredBackgroundHeight = view.frame.height - footerSprite.size.height
        
        if backgroundWidth >= view.frame.width {
            backgroundSprite.size = CGSize(width: backgroundWidth, height: desiredBackgroundHeight)
            backgroundSprite.position = CGPoint(x: -(backgroundWidth - view.frame.width)/2.0, y: footerSprite.size.height)
        } else if backgroundHeight >= desiredBackgroundHeight {
            backgroundSprite.size = CGSize(width: view.frame.width, height: backgroundHeight)
            backgroundSprite.position = CGPoint(x: 0, y: footerSprite.size.height - ((backgroundHeight - desiredBackgroundHeight)/2.0))
        } else {
            // i have no idea
            assert(false, "oh no")
        }
        
        gameLayer.addChild(backgroundSprite)
        gameLayer.addChild(footerSprite)
        
        let allTilesWidth = tileWidth * CGFloat(numColumns)
        let allSpacingWidth = tileSpacing * CGFloat(numColumns-1)
        let allTilesHeight = tileHeight * CGFloat(numRows)
        let allSpacingHeight = tileSpacing * CGFloat(numRows - 1)

        let underLayExtraPadding: CGFloat = 12
        let underlayLayer = SKSpriteNode(color: .black.withAlphaComponent(0.4), size: CGSize(width: allTilesWidth + underLayExtraPadding + allSpacingWidth, height: allTilesHeight + allSpacingHeight + underLayExtraPadding))
        underlayLayer.anchorPoint = .zero
        
        let layerPosition = CGPoint(
            x: (size.width - (allTilesWidth + allSpacingWidth))/2.0,
            y: footerSprite.size.height + 45) // TODO: we need to be flexible here for different phone sizes
        
        candiesLayer.position = layerPosition
        underlayLayer.position = CGPoint(x: layerPosition.x - underLayExtraPadding/2.0, y: layerPosition.y - underLayExtraPadding/2.0)
        gameLayer.addChild(underlayLayer)
        gameLayer.addChild(candiesLayer)

        
    }
    
    func clearSprites(animted: Bool = false, completion: (()->Void)?) {
        if animted {
            let candies = level.allCandies()
            animate(scaleIn: false, candies: candies) {
                self.candiesLayer.removeAllChildren()
                completion?()
            }
        } else {
            candiesLayer.removeAllChildren()
        }
    }

    func addSprites(for candies: Set<Candy>, animated: Bool = false, completion: (()->Void)? = nil) {
        for candy in candies {
            addSprite(for: candy)
        }
        
        if animated {
            for candy in candies {
                candy.sprite?.xScale = 0.0
                candy.sprite?.yScale = 0.0
            }
            animate(scaleIn: true, candies: Array(candies)) {
                completion?()
            }
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
    
// MARK: - Animations
    
    func animate(scaleIn: Bool, candies: [Candy?], completion: (() -> Void)?) {
        let duration = 0.3
        candies.forEach { candy in
            let fade = SKAction.scale(to: scaleIn ? 1.0 : 0.0, duration: duration)
            candy?.sprite?.run(fade)
        }
        
        run(SKAction.wait(forDuration: duration)) {
            completion?()
        }
    }
    
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
    
    func animateMatchedCandies(for chains: Set<Chain>, comboLevel: Int, completion: @escaping () -> Void) {
        var burst = [SKAction.burstSound(comboLevel: comboLevel)]
        for chain in chains {
            animateScore(for: chain)
            for candy in chain.candies {
                if let sprite = candy.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence(burst + [scaleAction, SKAction.removeFromParent()]),
                                   withKey: "removing")
                        burst = [] // Only add one sound action for the chain.
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
        
        let scoreLabel = SKLabelNode(fontNamed: "Kenney-Mini-Square")
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

