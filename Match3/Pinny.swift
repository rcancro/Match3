//
//  Pinny.swift
//  Match3
//
//  Created by Ricky Cancro on 7/13/21.
//

import SpriteKit

class Pinny : SKSpriteNode {
    
    let pinnyAnimatedAtlas = SKTextureAtlas(named: "pinny")
    let spriteSize = CGSize(width: 20, height: 34)
    let walkSpriteCount = 4
    
    var spriteCount: Int = 1
    
    private var sadFrames = 0
    
    init() {
        super.init(texture: pinnyAnimatedAtlas.textureNamed("1"), color: UIColor.clear, size: spriteSize)
    }
    
    func incrementSpriteCount() {
        self.spriteCount = (self.spriteCount + 1) % walkSpriteCount;
    }
    
    func animate() {
        let wait = SKAction.wait(forDuration: 0.5)
        let changeSprite = SKAction.run { [weak self] in
            guard let strongSelf = self else { return }
            
            var spriteName = ""
            let blink = arc4random_uniform(10) == 5
            
            switch(strongSelf.spriteCount) {
            case 0:
                if strongSelf.sadFrames > 0 {
                    spriteName = "1-sad"
                } else {
                    spriteName = blink ? "1-blink" : "1"
                }
            case 1, 3:
                if strongSelf.sadFrames > 0 {
                    spriteName = "2-sad"
                } else {
                    spriteName = blink ? "2-blink" : "2"
                }
            case 2:
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
            strongSelf.texture = strongSelf.pinnyAnimatedAtlas.textureNamed(spriteName)
            
        }
        
        run(SKAction.repeatForever(SKAction.sequence([wait, changeSprite])))
    }
    
    func makeSad() {
        sadFrames = 6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
