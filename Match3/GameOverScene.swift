//
//  GameOverScene.swift
//  Match3
//
//  Created by emma herold on 7/14/21.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    let gameOverLayer = SKNode()
    var backgroundLayer: GameOverBackgroundLayer?
        
    override init(size: CGSize) {
        super.init(size: size)
        addChild(gameOverLayer)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // this is gross, but i don't want to have to lay everything out again when we get the safe area insets
        let insets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        
        backgroundLayer = GameOverBackgroundLayer(size: view.frame.size, insets: insets)
        backgroundLayer?.animate(true)
        gameOverLayer.addChild(backgroundLayer!)
        run(SKAction.playSoundFileNamed("death", waitForCompletion: false))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

