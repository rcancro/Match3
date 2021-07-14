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
    var backgroundLayer: GameBackgroundLayer?
    var footerHeight: CGFloat {
        if let background = backgroundLayer {
            return background.footerHeight
        }
        return 0
    }
    
    private var hapticManager: HapticManager?
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    var swipeHandler: ((Swap) -> Void)?
    let startLabel = SKLabelNode()
    let beepAction: SKAction
    let goAction: SKAction
    var pinny: Pinny? = nil
    let backgroundSound = SKAudioNode(fileNamed: "scary.mp3")

    override init(size: CGSize) {
        beepAction = SKAction.startBeepSound()
        goAction = SKAction.goBeepSound()
        super.init(size: size)
        addChild(gameLayer)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Make sure the haptic manager is available when the scene appears.
        hapticManager = HapticManager()

        // this is gross, but i don't want to have to lay everything out again when we get the safe area insets
        let insets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        
        backgroundLayer = GameBackgroundLayer(size: view.frame.size, insets: insets)
        backgroundLayer?.animate(true)
        gameLayer.addChild(backgroundLayer!)
        
        
        let allTilesWidth = tileWidth * CGFloat(numColumns)
        let allSpacingWidth = tileSpacing * CGFloat(numColumns-1)
        let allTilesHeight = tileHeight * CGFloat(numRows)
        let allSpacingHeight = tileSpacing * CGFloat(numRows - 1)

        let underLayExtraPadding: CGFloat = 12
        let underlayLayer = SKSpriteNode(color: .black.withAlphaComponent(0.4), size: CGSize(width: allTilesWidth + underLayExtraPadding + allSpacingWidth, height: allTilesHeight + allSpacingHeight + underLayExtraPadding))
        underlayLayer.anchorPoint = .zero
        
        let layerPosition = CGPoint(
            x: (size.width - (allTilesWidth + allSpacingWidth))/2.0,
            y: backgroundLayer!.footerMaxY + 45) // TODO: we need to be flexible here for different phone sizes
        
        candiesLayer.position = layerPosition
        underlayLayer.position = CGPoint(x: layerPosition.x - underLayExtraPadding/2.0, y: layerPosition.y - underLayExtraPadding/2.0)
        gameLayer.addChild(underlayLayer)
        gameLayer.addChild(candiesLayer)
        startLabel.position = view.center
    }

    
    func startCountDown(completion: @escaping ()->Void, aboutToCompletion: (()->Void)?) {
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 1)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.1)
        let readySeq = SKAction.sequence([beepAction, SKAction.wait(forDuration: 0.1), fadeInAction, fadeOutAction])
        
        let goGroup = SKAction.group([fadeOutAction, goAction])
        
        startLabel.zPosition = 1000
        startLabel.fontName = UIFont.customFontName
        startLabel.text = "3"
        startLabel.fontColor = .halloweenYellowGreen
        startLabel.alpha = 0.0
        startLabel.fontSize = 100
        addChild(self.startLabel)

        // give the sound time to load the first time
        run(.wait(forDuration: 0.1)) {
        
            self.startLabel.run(readySeq) {
                self.startLabel.text = "2"
                self.startLabel.run(readySeq) {
                    self.startLabel.text = "1"
                    self.startLabel.run(readySeq) {
                        self.startLabel.text = "GO!"
                        aboutToCompletion?()
                        self.startLabel.run(goGroup) {
                            self.startLabel.removeFromParent()
                            self.addChild(self.backgroundSound)
                            completion()
                        }
                    }
                }
            }
        }
    }

    func gameOver() {
        backgroundSound.removeFromParent()
    }
    
    func clearSprites(animated: Bool = false, completion: (()->Void)?) {
        
        if animated {
            let candies = level.allCandies()
            if candies.count > 0 {
                animate(scaleIn: false, candies: candies) {
                    self.candiesLayer.removeAllChildren()
                    completion?()
                }
            } else {
                //nothing to do
                completion?()
            }
        } else {
            candiesLayer.removeAllChildren()
            completion?()
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
        let scaleA1 = SKAction.scale(to: 1.3, duration: duration/2)
        let groupA = SKAction.group([moveA, scaleA1])
        
        let waitA = SKAction.wait(forDuration: duration/2)
        let scaleA2 = SKAction.scale(to: 1, duration: duration/2)
        let seqA = SKAction.sequence([waitA, scaleA2])
            
        moveA.timingMode = .easeOut
        scaleA1.timingMode = .linear
        scaleA2.timingMode = .linear
        
        spriteA.run(groupA, completion: completion)
        spriteA.run(seqA)

        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        let scaleB1 = SKAction.scale(to: 0.7, duration: duration/2)
        let groupB = SKAction.group([moveB, scaleB1])
        
        let waitB = SKAction.wait(forDuration: duration/2)
        let scaleB2 = SKAction.scale(to: 1, duration: duration/2)
        let seqB = SKAction.sequence([waitB, scaleB2])

        
        moveB.timingMode = .easeOut
        scaleB1.timingMode = .linear
        scaleB2.timingMode = .linear
        
        spriteB.run(groupB)
        spriteB.run(seqB)
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> Void) {
        let spriteA = swap.candyA.sprite!
        let spriteB = swap.candyB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        let scaleA1 = SKAction.scale(to: 1.3, duration: duration/2)
        let groupA = SKAction.group([moveA, scaleA1])
        
        let waitA = SKAction.wait(forDuration: duration/2)
        let scaleA2 = SKAction.scale(to: 1, duration: duration/2)
        let zPos = SKAction.run {
            spriteA.zPosition = 80
        }
        let seqA = SKAction.sequence([waitA, scaleA2, zPos])
            
        moveA.timingMode = .easeOut
        scaleA1.timingMode = .linear
        scaleA2.timingMode = .linear
        

        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        let scaleB1 = SKAction.scale(to: 0.7, duration: duration/2)
        let groupB = SKAction.group([moveB, scaleB1])
        
        let waitB = SKAction.wait(forDuration: duration/2)
        let scaleB2 = SKAction.scale(to: 1, duration: duration/2)
        let seqB = SKAction.sequence([waitB, scaleB2])

        
        moveB.timingMode = .easeOut
        scaleB1.timingMode = .linear
        scaleB2.timingMode = .linear
        
        spriteA.run(SKAction.sequence([groupA, groupB]), completion:completion)
        spriteA.run(SKAction.sequence([seqA, seqB]))

        spriteB.run(SKAction.sequence([groupB, groupA]))
        spriteB.run(SKAction.sequence([seqB, seqA]))
    }
    
    func animateMatchedCandies(for chains: Set<Chain>, comboLevel: Int, completion: @escaping () -> Void) {
        
        // check to see if this chain is all candy corn
        var allCandyCorn = true
        for chain in chains {
            for candy in chain.candies {
                allCandyCorn = allCandyCorn && candy.candyType == .candyCorn
                if !allCandyCorn {
                    break
                }
            }
        }
        
        if allCandyCorn {
            pinny?.makeSad()
        }
        
        var burst: [SKAction] = allCandyCorn ? [SKAction.badCandySound()] : [SKAction.burstSound(comboLevel: comboLevel)]
        hapticManager?.playCombo(comboLevel: comboLevel)
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

