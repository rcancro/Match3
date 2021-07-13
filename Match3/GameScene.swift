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
    var suppressTouches = false
    
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
        guard !suppressTouches, let touch = touches.first, let lastElement = lastElementInChain else { return }
        let location = touch.location(in: candiesLayer)
        let (success, column, row) = convertPoint(location)
        if success, let candy = level.candy(atColumn: column, row: row) {
            if candy.candyType != lastElement.candyType {
                endTouches()
                suppressTouches = true
            } else if currentChain.contains(candy), candy != lastElementInChain {
                endTouches()
                suppressTouches = true
            } else if !currentChain.contains(candy) && candy.isValidLocationForChain(currentChain){
                currentChain.append(candy)
                candy.highlight(true, atChainPosition: currentChain.count)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        suppressTouches = false
        endTouches()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        suppressTouches = false
        endTouches()
    }
    
    func endTouches() {
        // check to see if we have a chain.
        if currentChain.isValidChain() {
            // we matched, let's play some crazy animation
            handleMatches(currentChain)
        } else {
            // no match, lets deselect
            currentChain.deselectChain()
        }
        currentChain = [Candy]()
    }
    
    func handleMatches(_ chain: [Candy]) {
        
        if chain.count == 0 {
            self.view?.isUserInteractionEnabled = true
            return
        }
        
        self.view?.isUserInteractionEnabled = false
        chain.matchChain { [weak self] candies in
            guard let strongSelf = self else { return }

            strongSelf.level.removeCandies(candies)
            let fallingCandies = strongSelf.level.fillHoles()
            let toppedOffColumns = strongSelf.level.topUpCookies()
            
            strongSelf.animate(fallingCandies: fallingCandies, newCandies: toppedOffColumns) {
                strongSelf.view?.isUserInteractionEnabled = true
                
                // look for new chains in the newly moved tiles
                var combos = Set<Candy>()
                for column in fallingCandies {
                    if let candy = column.first {
                        if let chain = strongSelf.level.chain(atColumn: candy.column, row: candy.row) {
                            combos.formUnion(chain)
                        }
                    }
                }
                
//                // look for new chains in the new tiles
//                for column in toppedOffColumns {
//                    for candy in column {
//                        if let chain = strongSelf.level.chain(atColumn: candy.column, row: candy.row) {
//                            combos.formUnion(chain)
//                        }
//                    }
//                }
                
                strongSelf.handleMatches(Array(combos))

            }
        }
    }
    
    func animate(fallingCandies: [[Candy]], newCandies: [[Candy]], completion: @escaping () -> Void) {
        
        animateFallingCandies(in: fallingCandies) {
            
        }
        
        run(SKAction.wait(forDuration: 0.2)) {
            self.animateNewCandies(in: newCandies, completion: completion)
        }

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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

