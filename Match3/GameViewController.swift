//
//  GameViewController.swift
//  Match3
//
//  Created by ricky cancro on 7/11/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var level: Level!
    var scene: GameScene!
    var skView: SKView!
    
    func beginGame() {
      shuffle()
    }

    func shuffle() {
      let newCookies = level.shuffle()
      scene.addSprites(for: newCookies)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.backgroundColor = .green
        
        skView.isMultipleTouchEnabled = false
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        level = Level()
        scene.level = level
        scene.backgroundColor = .purple
        scene.swipeHandler = handleSwipe
        
        // Present the scene.
        skView.presentScene(scene)
        beginGame()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        level.performSwap(swap)
        scene.animate(swap, completion: handleMatches)
    }

    func handleMatches() {
        let chains = level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedCandies(for: chains) {
            let fallingColumns = self.level.fillHoles()
            let newColumns = self.level.topUpCookies()
            self.scene.animate(fallingCandies: fallingColumns, newCandies: newColumns) {
                self.handleMatches()
            }
        }
    }

    func beginNextTurn() {
        view.isUserInteractionEnabled = true
    }

}
