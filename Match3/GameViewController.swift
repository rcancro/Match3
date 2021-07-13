//
//  GameViewController.swift
//  Match3
//
//  Created by ricky cancro on 7/11/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameVCDelegate {

    var level: Level!
    var scene: GameScene!
    var skView: SKView!
    
    let scoreLabel = UILabel()
    let scoreValueLabel = UILabel()
    var _score: Int = 0
    var score: Int {
        get {
            return self._score
        }
        set {
            self._score = newValue
            updateLabels(animated: true)
        }
    }

    var gameOverOverlay: GameOverOverlay!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    func beginGame() {
        score = 0
        level.resetComboMultiplier()
        shuffle()
        // TODO: Once the timer label is moved to the GameViewController, we should reset the timer here too
        scene.timerLabel.startWithDuration(duration: 15)
    }

    func shuffle() {
      let newCookies = level.shuffle()
      scene.clearSprites()
      scene.addSprites(for: newCookies)
    }
    
    private func customFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Kenney-Future-Square", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = SKView(frame: view.bounds)
        view.addSubview(skView)

        scoreLabel.font = customFont(ofSize: 16)
        scoreLabel.text = "SCORE"
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .white

        view.addSubview(scoreLabel)
        scoreValueLabel.font = customFont(ofSize: 18)
        view.addSubview(scoreValueLabel)
        scoreValueLabel.adjustsFontSizeToFitWidth = true
        scoreValueLabel.text = "0"
        scoreValueLabel.textAlignment = .center
        scoreValueLabel.textColor = .white

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.backgroundColor = .green
        
        skView.isMultipleTouchEnabled = false
        
        gameOverOverlay = GameOverOverlay(frame: skView.frame)
        gameOverOverlay.isHidden = true
        view.addSubview(gameOverOverlay)

        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size, del: self)
        level = Level()
        scene.level = level
        scene.backgroundColor = .purple
        scene.swipeHandler = handleSwipe

        // Present the scene.
        skView.presentScene(scene)
        beginGame()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let xMargins: CGFloat = 16
        let yMargins: CGFloat = 4
        let labelPadding: CGFloat = 2
        let maxScoreWidth = view.frame.width * 0.3
        let scoreSize = scoreLabel.sizeThatFits(CGSize(width: maxScoreWidth, height: 80000))
        scoreLabel.frame = CGRect(x: xMargins, y: view.safeAreaInsets.top + yMargins, width: maxScoreWidth, height: scoreSize.height)
        
        let scoreValueSize = scoreValueLabel.sizeThatFits(CGSize(width: maxScoreWidth, height: 80000))
        scoreValueLabel.frame = CGRect(x: xMargins, y: scoreLabel.frame.maxY + labelPadding, width: maxScoreWidth, height: scoreValueSize.height)
    }
    
    private func updateLabels(animated: Bool) {
        self.scoreValueLabel.text = "\(score)"
        
        if animated {
            UIView.animate(withDuration: 0.15) {
                self.scoreValueLabel.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            } completion: { finished in
                UIView.animate(withDuration: 0.15) {
                    self.scoreValueLabel.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                }
            }
        }
    }
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animate(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
              self.view.isUserInteractionEnabled = true
            }
        }
    }

    func handleMatches() {
        let chains = level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedCandies(for: chains) {
            for chain in chains {
              self.score += chain.score
            }
//            self.updateLabels(animated: true)
            
            let fallingColumns = self.level.fillHoles()
            let newColumns = self.level.topUpCookies()
            self.scene.animate(fallingCandies: fallingColumns, newCandies: newColumns) {
                self.handleMatches()
            }
        }
    }

    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
    }
    
    func showGameOver() {
        // This can be called repeatedly, so we'll only do the work
        // if it hasn't been done yet
        if (gameOverOverlay.isHidden) {
            gameOverOverlay.score = self.score
            gameOverOverlay.isHidden = false
            scene.isUserInteractionEnabled = false
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    @objc func hideGameOver() {
        if (!gameOverOverlay.isHidden) {
            view.removeGestureRecognizer(tapGestureRecognizer)
            tapGestureRecognizer = nil
            gameOverOverlay.isHidden = true
            scene.isUserInteractionEnabled = true
            beginGame()
        }
    }

// MARK: - GameVCDelegate
    func gameOver() {
        showGameOver()
    }

}
