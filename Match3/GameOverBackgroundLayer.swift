//
//  GameOverBackgroundLayer.swift
//  Match3
//
//  Created by emma herold on 7/14/21.
//

import SpriteKit

class GameOverBackgroundLayer : SKNode {
    
    let backgroundSprite = SKSpriteNode(imageNamed: "game-over-background-2")
    
    var spriteCounter: Int = 0

    init(size: CGSize, insets: UIEdgeInsets) {
        super.init()
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.position = .zero
        backgroundSprite.zPosition = -1
        
        let backgroundWidth = floor((size.height * backgroundSprite.size.width)/backgroundSprite.size.height)
        let backgroundHeight = floor((backgroundSprite.size.height * size.width)/backgroundSprite.size.width)
        let desiredBackgroundHeight = size.height
        
        if backgroundWidth >= size.width {
            backgroundSprite.size = CGSize(width: backgroundWidth, height: desiredBackgroundHeight)
            backgroundSprite.position = CGPoint(x: -(backgroundWidth - size.width)/2.0, y: 0)
        } else if backgroundHeight >= desiredBackgroundHeight {
            backgroundSprite.size = CGSize(width: size.width, height: backgroundHeight)
            backgroundSprite.position = CGPoint(x: 0, y: (backgroundHeight - desiredBackgroundHeight)/2.0)
        } else {
            // i have no idea
            assert(false, "oh no")
            backgroundSprite.position = CGPoint(x: 0, y: 0)
        }
        
        addChild(backgroundSprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update() {
        if spriteCounter == 0 {
            backgroundSprite.texture = SKTexture(imageNamed: "game-over-background-1")
        } else if spriteCounter == 1 {
            backgroundSprite.texture = SKTexture(imageNamed: "game-over-background-2")
        }
        
        spriteCounter += 1
        if spriteCounter > 1 {
            spriteCounter = 0
        }
    }
    
    func animate(_ doAnimate: Bool) {
        if doAnimate {
            let wait = SKAction.wait(forDuration: 0.5)
            let update = SKAction.run {
                self.update()
            }
            let seq = SKAction.sequence([wait,update])
            run(SKAction.repeatForever(seq))
        } else {
            removeAllActions()
        }
    }

}
