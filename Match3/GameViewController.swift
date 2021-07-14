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
    let pinny = Pinny()

    let yMargins: CGFloat = 4
    
    let shuffleButton = UIButton(type: .custom)
    
    var wiggleTimer = Timer()
    
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
    var gameOverTapGestureRecognizer: UITapGestureRecognizer!
    
    func beginGame() {
        score = 0
        level.resetComboMultiplier()
        timeValueLabel.setTime(duration: level.baseLevelTime)
        timeValueLabel.startCountdown()
        restartHintTimer()
        shuffle()
    }

    func shuffle() {
        scene.clearSprites(animted: true) {
            let newCookies = self.level.shuffle()
            self.scene.addSprites(for: newCookies, animated: true) {
                self.restartHintTimer()
            }
        }
    }
    
    private func customFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Kenney-Mini-Square", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        level = Level()
        
        // preload our sounds
        let _ = SKAction.burstSound(comboLevel: 0)

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
        
        shuffleButton.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        shuffleButton.setTitle("SHUFFLE", for: .normal)
        shuffleButton.setTitleColor(.black, for: .normal)
        shuffleButton.titleLabel?.font = customFont(ofSize: 24)
        shuffleButton.titleLabel?.textAlignment = .center
        shuffleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        shuffleButton.addTarget(self, action: #selector(handleShuffleButtonTapped), for: .touchUpInside)
        view.addSubview(shuffleButton)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.backgroundColor = .green
        
        skView.isMultipleTouchEnabled = false
        
        gameOverOverlay = GameOverOverlay(frame: skView.frame)
        gameOverOverlay.isHidden = true
        view.addSubview(gameOverOverlay)

        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        level = Level()
        scene.level = level
        scene.backgroundColor = UIColor.color(fromHexValue: 0x974D15)
        scene.swipeHandler = handleSwipe
        
        pinny.animate()
        scene.addChild(pinny)

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
        let labelPadding: CGFloat = 2
        let maxLabelWidth = ceil(view.frame.width * 0.3)
        
        let scoreSize = scoreLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        scoreLabel.frame = CGRect(x: xMargins, y: view.safeAreaInsets.top + yMargins, width: maxLabelWidth, height: scoreSize.height)
        
        let scoreValueSize = scoreValueLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        scoreValueLabel.frame = CGRect(x: xMargins, y: scoreLabel.frame.maxY + labelPadding, width: maxLabelWidth, height: scoreValueSize.height)
        
        let timeSize = timeLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        timeLabel.frame = CGRect(x: view.frame.width - (xMargins + maxLabelWidth), y: view.safeAreaInsets.top + yMargins, width: maxLabelWidth, height: timeSize.height)
        
        let timeValueSize = timeValueLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        timeValueLabel.frame = CGRect(x: view.frame.width - (xMargins + maxLabelWidth), y: scoreLabel.frame.maxY + labelPadding, width: maxLabelWidth, height: timeValueSize.height)
        
        let unionRect = timeValueLabel.frame.union(timeLabel.frame)
        pinny.position = CGPoint(x: view.center.x, y: view.frame.height - unionRect.midY)

        let shuffleLabelSize = shuffleButton.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        let minHeight: CGFloat = shuffleButton.image(for: .normal)?.size.height ?? 0
        let buttonHeight = max(minHeight, shuffleLabelSize.height)
        shuffleButton.frame = CGRect(x: view.frame.midX - (maxLabelWidth/2), y: view.frame.height - (view.safeAreaInsets.bottom + buttonHeight + (scene.footerHeight - buttonHeight)/2.0) , width:maxLabelWidth, height: max(minHeight, buttonHeight))
    }
    
    @objc func handleShuffleButtonTapped() {
        shuffle()
        self.timeValueLabel.addTime(duration: level.shufflePenalityTime)
    }
    
    func restartHintTimer() {
        wiggleTimer.invalidate()
        wiggleTimer = Timer.scheduledTimer(withTimeInterval: level.hintDelayTime, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else { return }
            strongSelf.wiggleHint()
        })
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
        handleMatches(comboLevel: 0)
    }

    func handleMatches(comboLevel: Int) {
        let chains = level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        restartHintTimer()
        scene.animateMatchedCandies(for: chains, comboLevel: comboLevel) {
            for chain in chains {
                self.score += chain.score
                self.timeValueLabel.addTime(duration: chain.bonusTime)
            }
            
            let fallingColumns = self.level.fillHoles()
            let newColumns = self.level.topUpCookies()
            self.scene.animate(fallingCandies: fallingColumns, newCandies: newColumns) {
                self.handleMatches(comboLevel: comboLevel + 1)
            }
        }
    }

    private func updateLabels(animated: Bool) {
        self.scoreValueLabel.text = "\(score)"
        
        if animated {
            scoreValueLabel.bumpAnimation()
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
            wiggleTimer.invalidate()
            gameOverOverlay.score = self.score
            gameOverOverlay.isHidden = false
            scene.isUserInteractionEnabled = false
            self.gameOverTapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(hideGameOver))
            self.view.addGestureRecognizer(self.gameOverTapGestureRecognizer)
        }
    }
    
    @objc func hideGameOver() {
        if (!gameOverOverlay.isHidden) {
            view.removeGestureRecognizer(gameOverTapGestureRecognizer)
            gameOverTapGestureRecognizer = nil
            gameOverOverlay.isHidden = true
            scene.isUserInteractionEnabled = true
            beginGame()
        }
    }
    
    func wiggleHint() {
        if (level.possibleSwaps.count > 0) {
            let swap = level.possibleSwaps.randomElement()
            swap?.candyA.wiggle()
            swap?.candyB.wiggle()
        }
    }

}

extension GameViewController : CountdownLabelDelegate {
    
    func countdownLabelDidExpire(_ countdownLabel: CountdownLabel) {
        // game over
        showGameOver()
    }
    
}
