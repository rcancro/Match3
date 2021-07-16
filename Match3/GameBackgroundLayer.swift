//
//  GameBackgroundLayer.swift
//  Match3
//
//  Created by Ricky Cancro on 7/14/21.
//

import SpriteKit

class GameBackgroundLayer : SKNode {
    
    let backgroundSprite = SKSpriteNode(imageNamed: "game-background-2")
    let footerSprite = SKSpriteNode(imageNamed: "footer-2")
    
    var spriteCounter: Int = 0
    
    var footerMaxY: CGFloat {
        return footerSprite.position.y + footerSprite.size.height
    }

    var footerHeight: CGFloat {
        return footerSprite.size.height
    }
    
    var animationAction: SKAction?

    init(size: CGSize, insets: UIEdgeInsets) {
        super.init()
        backgroundSprite.anchorPoint = .zero
        backgroundSprite.position = .zero
        backgroundSprite.zPosition = -1
        
        footerSprite.centerRect = CGRect(x: 0.3, y: 0, width: 0.1, height: 0)
        footerSprite.anchorPoint = .zero
        footerSprite.zPosition = 0
        footerSprite.size = CGSize(width: size.width, height: footerSprite.size.height)
        update(with: size, insets: insets)
        addChild(backgroundSprite)
        addChild(footerSprite)
    }
    
    func update(with size: CGSize, insets: UIEdgeInsets) {
        let footerHeight = footerSprite.size.height + insets.bottom
        
        let backgroundWidth = floor(((size.height - footerHeight) * backgroundSprite.size.width)/backgroundSprite.size.height)
        let backgroundHeight = floor((backgroundSprite.size.height * size.width)/backgroundSprite.size.width)
        let desiredBackgroundHeight = size.height - footerHeight
        
        if backgroundWidth >= size.width {
            backgroundSprite.size = CGSize(width: backgroundWidth, height: desiredBackgroundHeight)
            backgroundSprite.position = CGPoint(x: -(backgroundWidth - size.width)/2.0, y: footerHeight)
        } else if backgroundHeight >= desiredBackgroundHeight {
            backgroundSprite.size = CGSize(width: size.width, height: backgroundHeight)
            backgroundSprite.position = CGPoint(x: 0, y: footerHeight - ((backgroundHeight - desiredBackgroundHeight)/2.0))
        } else {
            // i have no idea
            assert(false, "oh no")
            backgroundSprite.position = CGPoint(x: 0, y: footerHeight)
        }
        
        footerSprite.position = CGPoint(x: 0, y: insets.bottom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update() {
        if spriteCounter == 0 {
            backgroundSprite.texture = SKTexture(imageNamed: "game-background-1")
            footerSprite.texture = SKTexture(imageNamed: "footer-1")
        } else if spriteCounter == 1 {
            backgroundSprite.texture = SKTexture(imageNamed: "game-background-2")
            footerSprite.texture = SKTexture(imageNamed: "footer-2")
        }
        
        spriteCounter += 1
        if spriteCounter > 1 {
            spriteCounter = 0
        }
    }
    
    func increaseSpeed(to factor: CGFloat, duration: TimeInterval) {
        run(.speed(to: factor, duration: duration))
    }

    func animate(_ doAnimate: Bool) {
        if doAnimate {
            let wait = SKAction.wait(forDuration: 0.5)
            let update = SKAction.run {
                self.update()
            }
            animationAction = SKAction.sequence([wait,update])
            run(SKAction.repeatForever(animationAction!))
        } else {
            removeAllActions()
            animationAction = nil
        }
    }

}
