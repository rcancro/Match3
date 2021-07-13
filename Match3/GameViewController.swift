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
    
    let scoreLabel = UILabel()
    let scoreValueLabel = UILabel()
    
    let timeLabel = UILabel()
    let timeValueLabel = CountdownLabel()
    
    var score = 0

    func beginGame() {
        level.resetComboMultiplier()
        timeValueLabel.startCountdown()
        timeValueLabel.setTime(duration: level.baseLevelTime)
        shuffle()
    }

    func shuffle() {
      let newCookies = level.shuffle()
      scene.addSprites(for: newCookies)
    }
    
    private func customFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Kenney-Future-Square", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        level = Level()

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
                
        timeLabel.font = customFont(ofSize: 16)
        timeLabel.text = "TIME"
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        view.addSubview(timeLabel)
        
        timeValueLabel.font = customFont(ofSize: 18)
        view.addSubview(timeValueLabel)
        timeValueLabel.adjustsFontSizeToFitWidth = true
        timeValueLabel.text = "0"
        timeValueLabel.textAlignment = .center
        timeValueLabel.textColor = .white
        timeValueLabel.setTime(duration: level.baseLevelTime)
        timeValueLabel.delegate = self

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.backgroundColor = .green
        
        skView.isMultipleTouchEnabled = false
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
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
        let maxLabelWidth = view.frame.width * 0.3
        
        let scoreSize = scoreLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        scoreLabel.frame = CGRect(x: xMargins, y: view.safeAreaInsets.top + yMargins, width: maxLabelWidth, height: scoreSize.height)
        
        let scoreValueSize = scoreValueLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        scoreValueLabel.frame = CGRect(x: xMargins, y: scoreLabel.frame.maxY + labelPadding, width: maxLabelWidth, height: scoreValueSize.height)
        
        let timeSize = timeLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        timeLabel.frame = CGRect(x: view.frame.width - (xMargins + maxLabelWidth), y: view.safeAreaInsets.top + yMargins, width: maxLabelWidth, height: timeSize.height)
        
        let timeValueSize = timeValueLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        timeValueLabel.frame = CGRect(x: view.frame.width - (xMargins + maxLabelWidth), y: scoreLabel.frame.maxY + labelPadding, width: maxLabelWidth, height: timeValueSize.height)

    }
    
    private func updateLabels(animated: Bool) {
        self.scoreValueLabel.text = "\(score)"
        
        if animated {
            scoreValueLabel.bumpAnimation()
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
                self.timeValueLabel.addTime(duration: chain.bonusTime)
            }
            self.updateLabels(animated: true)
            
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

}

extension GameViewController : CountdownLabelDelegate {
    
    func countdownLabelDidExpire(_ countdownLabel: CountdownLabel) {
        // game over
        scene.gameOver()
    }
    
}
