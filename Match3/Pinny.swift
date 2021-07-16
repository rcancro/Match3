//
//  Pinny.swift
//  Match3
//
//  Created by Ricky Cancro on 7/13/21.
//

import SpriteKit

class Pinny : SKSpriteNode {
    
    let pinnyAnimatedAtlas = SKTextureAtlas(named: "pinny")
    let walkSpriteCount = 4
    
    var additionalAction: SKAction?
    
    private var spriteCount: Int = 1
    private var currentSpriteName: String?
    
    private var sadFrames = 0
    
    init() {
        let spriteSize = CGSize(width: 78, height: 127)
        super.init(texture: pinnyAnimatedAtlas.textureNamed("1"), color: UIColor.clear, size: spriteSize)
    }
    
    func incrementSpriteCount() {
        self.spriteCount = (self.spriteCount + 1) % walkSpriteCount;
    }
    
    func makeCompact() {
        self.size = CGSize(width: 39, height: 63)
    }
    
    func isBent() -> Bool {
        if let spriteName = currentSpriteName {
            return spriteName.prefix(1) != "1"
        }
        return false
    }
    
    func increaseSpeed(to factor: CGFloat, duration: TimeInterval) {
        run(.speed(to: factor, duration: duration))
    }
    
    func animate() {
        let wait = SKAction.wait(forDuration: 0.5)
        let changeSprite = SKAction.run { [weak self] in
            guard let strongSelf = self else { return }
            
            var spriteName = ""
            let blink = arc4random_uniform(10) == 5
            
            switch(strongSelf.spriteCount) {
            case 0,2:
                if strongSelf.sadFrames > 0 {
                    spriteName = "1-sad"
                } else {
                    spriteName = blink ? "1-blink" : "1"
                }
            case 1:
                if strongSelf.sadFrames > 0 {
                    spriteName = "2-sad"
                } else {
                    spriteName = blink ? "2-blink" : "2"
                }
            case 3:
                if strongSelf.sadFrames > 0 {
                    spriteName = "3-sad"
                } else {
                    spriteName = blink ? "3-blink" : "3"
                }
            default:
                spriteName = "1"
                
            }
            
            if strongSelf.sadFrames > 0 {
                strongSelf.sadFrames = strongSelf.sadFrames - 1
            }
            strongSelf.incrementSpriteCount()
            strongSelf.currentSpriteName = spriteName
            strongSelf.texture = strongSelf.pinnyAnimatedAtlas.textureNamed(spriteName)
            
        }
        
        if let additionalAction = additionalAction {
            let group = SKAction.group([changeSprite, additionalAction])
            let animationAction = SKAction.repeatForever(SKAction.sequence([wait, group]))
            run(animationAction)
        } else {
            let animationAction = SKAction.repeatForever(SKAction.sequence([wait, changeSprite]))
            run(animationAction)
        }
    }
    
    func makeSad() {
        sadFrames = 6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
