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
    let tileSpacing: CGFloat = 4.0
    
    let gameLayer = SKNode()
    let candiesLayer = SKNode()
    
    override init(size: CGSize) {
        super.init(size: size)
        
        addChild(gameLayer)
        
        let allTilesWidth = tileWidth * CGFloat(numColumns)
        let allSpacingWidth = tileSpacing * CGFloat(numColumns-3) // why in the world do i have to subtact 3?
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
            x: (CGFloat(column) * tileWidth + tileWidth / 2) + (CGFloat(column - 1) * tileSpacing),
            y: (CGFloat(row) * tileHeight + tileHeight / 2) + (CGFloat(row - 1) * tileSpacing))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
