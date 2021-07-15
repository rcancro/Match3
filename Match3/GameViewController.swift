//
//  GameViewController.swift
//  Match3
//
//  Created by ricky cancro on 7/11/21.
//

import UIKit
import SpriteKit
import GameplayKit

var testingCombos = false
var skipInto = true

extension UIApplication {
    static var safeAreaInsetsAccordingToRicky: UIEdgeInsets {
        if let insets = UIApplication.shared.windows.first?.safeAreaInsets {
            return UIEdgeInsets(top: min(insets.top, 44), left: 0, bottom: min(insets.bottom, 16), right: 0)
        }
        return UIEdgeInsets(top: 44, left: 0, bottom: 16, right: 0)
    }
}

let numberFormatter = NumberFormatter()

class GameViewController: UIViewController {

    var level: Level = Level()
    var scene: GameScene? = nil

    var gameOverVC: GameOverViewController!
    var skView: SKView!
    
    let scoreLabel = UILabel()
    let scoreValueLabel = UILabel()
    
    let timeLabel = UILabel()
    let timeValueLabel = CountdownLabel()
    let pinny = Pinny()
    
    let shuffleButton = UIButton(type: .custom)
    
    var wiggleTimer = Timer()
    
    var _score: Int = 0
    var score: Int {
        get {
            return self._score
        }
        set {
            self._score = newValue
            updateLabels()
        }
    }
    
    let numberFormatter = NumberFormatter()
    
    func beginGame() {
        
        score = 0
        level.resetComboMultiplier()
        self.scene?.clearSprites(completion: {
            self.scene?.isPaused = false
            self.scene?.startCountDown {
                
                
                self.timeValueLabel.setTime(duration: self.level.baseLevelTime)
                self.timeValueLabel.startCountdown()
                self.restartHintTimer()
            } aboutToCompletion: {
                let newCookies = testingCombos ? self.level.setupManyCombos() : self.level.shuffle()
                self.scene?.addSprites(for: newCookies, animated: true) {
                    self.restartHintTimer()
                }
            }
        })
    }

    func shuffle() {
        scene?.clearSprites(animated: true) {
            let newCookies = testingCombos ? self.level.setupManyCombos() : self.level.shuffle()
            self.scene?.addSprites(for: newCookies, animated: true) {
                self.restartHintTimer()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        
        numberFormatter.locale = NSLocale.current
        numberFormatter.numberStyle = .decimal

        if skipInto {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            setupGame()
            transition(to: scene!, fromScene: nil)
        } else {
            let titleScene = TitleScene(size: skView.bounds.size)
            titleScene.sceneDelegate = self
            skView.presentScene(titleScene)
        }
    }
    
    func isCompact() -> Bool {
        return self.view.frame.height < 800
    }
    
    func setupGame() {

        // preload our sounds
        let _ = SKAction.burstSound(comboLevel: 0)
        let _ = SKAction.badCandySound()

        let compact = isCompact()
        let labelPointSizes: CGFloat = compact ? 16 : 18
        let valueLabelPointSizes: CGFloat = compact ? 30 : 32

        scoreLabel.font = UIFont.customFont(ofSize: labelPointSizes)
        scoreLabel.text = "SCORE"
        scoreLabel.textAlignment = .left
        scoreLabel.textColor = .halloweenPurple
        view.addSubview(scoreLabel)

        scoreValueLabel.font = UIFont.customFont(ofSize: valueLabelPointSizes)
        view.addSubview(scoreValueLabel)
        scoreValueLabel.adjustsFontSizeToFitWidth = true
        scoreValueLabel.text = "0"
        scoreValueLabel.textAlignment = .left
        scoreValueLabel.textColor = .halloweenYellowGreen

        timeLabel.font = UIFont.customFont(ofSize: labelPointSizes)
        timeLabel.text = "TIME"
        timeLabel.textAlignment = .left
        timeLabel.textColor = .halloweenPurple
        view.addSubview(timeLabel)

        timeValueLabel.font = UIFont.customFont(ofSize: valueLabelPointSizes)
        view.addSubview(timeValueLabel)
        timeValueLabel.adjustsFontSizeToFitWidth = true
        timeValueLabel.text = "0"
        timeValueLabel.textAlignment = .left
        timeValueLabel.textColor = .halloweenYellowGreen
        timeValueLabel.setTime(duration: level.baseLevelTime)
        timeValueLabel.delegate = self

        shuffleButton.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        shuffleButton.setTitle("SHUFFLE", for: .normal)
        shuffleButton.setTitleColor(.black, for: .normal)
        shuffleButton.titleLabel?.font = UIFont.customFont(ofSize: 24)
        shuffleButton.titleLabel?.textAlignment = .center
        shuffleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        shuffleButton.addTarget(self, action: #selector(handleShuffleButtonTapped), for: .touchUpInside)
        view.addSubview(shuffleButton)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.backgroundColor = .green

        skView.isMultipleTouchEnabled = false

        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene?.pinny = pinny // this is lazy. I'm sorry.
        if (compact) {
            pinny.makeCompact()
        }
        
        level = Level()
        scene?.level = level
        scene?.backgroundColor = UIColor.color(fromHexValue: 0x974D15)
        scene?.swipeHandler = handleSwipe
        scene?.isPaused = true

        pinny.animate()
        scene?.addChild(pinny)
    }
    
    func transition(to gameScene: GameScene, fromScene previousScene: SKScene?) {
        if let _ = previousScene {
            skView.presentScene(gameScene, transition: SKTransition.reveal(with: .down, duration: 0.4))
        } else {
            skView.presentScene(gameScene)
        }
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
        
        guard let scene = scene else { return }
    
        let xMargins: CGFloat = 16
        let sameLabelSpacing: CGFloat = -8 // spacing between the label and the value label
        let labelSpacing: CGFloat = 8
        let yOffset: CGFloat = scene.availableTopPadding
        let safeAreaInsets = UIApplication.safeAreaInsetsAccordingToRicky
        let maxLabelWidth = ceil(view.frame.width * 0.5) - xMargins

        if isCompact() {

            let gameboardXOffset = (view.frame.width - scene.gameBoardSize.width)/2.0
            let pinnyRect = CGRect(x: gameboardXOffset - pinny.size.width/2.0, y: yOffset, width: pinny.size.width, height: pinny.size.height)
            pinny.position = CGPoint(x: pinnyRect.maxX, y: view.frame.height - pinnyRect.midY)
            let labelXOffset = gameboardXOffset + pinny.size.width + xMargins
            
            
            let timeSize = timeLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
            var timeValueSize = timeValueLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
            // we support 3 digits, but probably only have 2 in there right now
            timeValueSize.width *= 1.5


            let scoreMaxLabelWidth: CGFloat = view.frame.width - timeSize.width - gameboardXOffset - labelXOffset - xMargins
            
            let scoreSize = scoreLabel.sizeThatFits(CGSize(width: scoreMaxLabelWidth, height: 80000))
            let scoreValueSize = scoreValueLabel.sizeThatFits(CGSize(width: scoreMaxLabelWidth, height: 80000))
            let labelHeight = scoreSize.height + scoreValueSize.height + sameLabelSpacing
            
            scoreLabel.frame = CGRect(x: labelXOffset, y: (pinnyRect.height - labelHeight) , width: scoreMaxLabelWidth, height: scoreSize.height)
            scoreLabel.textAlignment = .center
            scoreValueLabel.frame = CGRect(x: labelXOffset, y: scoreLabel.frame.maxY + sameLabelSpacing, width: scoreMaxLabelWidth, height: scoreValueSize.height)
            scoreValueLabel.textAlignment = .center
            
            timeLabel.textAlignment = .right
            timeLabel.frame = CGRect(x: view.frame.width - timeSize.width - gameboardXOffset, y: (pinnyRect.height - labelHeight), width: timeSize.width, height: timeSize.height)
            timeValueLabel.textAlignment = .right
            timeValueLabel.frame = CGRect(x: view.frame.width - timeValueSize.width - gameboardXOffset, y: timeLabel.frame.maxY + sameLabelSpacing, width: timeValueSize.width, height: timeValueSize.height)
            
        } else {
            let labelXOffset = view.frame.width/2.0

            let scoreSize = scoreLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
            scoreLabel.frame = CGRect(x: labelXOffset, y: safeAreaInsets.top + yOffset, width: maxLabelWidth, height: scoreSize.height)
            
            let scoreValueSize = scoreValueLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
            scoreValueLabel.frame = CGRect(x: labelXOffset, y: scoreLabel.frame.maxY + sameLabelSpacing, width: maxLabelWidth, height: scoreValueSize.height)
            
            let timeSize = timeLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
            timeLabel.frame = CGRect(x: labelXOffset, y: scoreValueLabel.frame.maxY + labelSpacing, width: maxLabelWidth, height: timeSize.height)
            
            let timeValueSize = timeValueLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
            timeValueLabel.frame = CGRect(x: labelXOffset, y: timeLabel.frame.maxY + sameLabelSpacing, width: maxLabelWidth, height: timeValueSize.height)
            
            let pinnyRect = CGRect(x: 0, y: scoreLabel.frame.origin.y, width: labelXOffset, height: timeValueLabel.frame.maxY - scoreLabel.frame.origin.y)
            pinny.position = CGPoint(x: pinnyRect.midX, y: view.frame.height - pinnyRect.midY)
        }
        
        let shuffleLabelSize = shuffleButton.sizeThatFits(CGSize(width: maxLabelWidth, height: 80000))
        let minHeight: CGFloat = shuffleButton.image(for: .normal)?.size.height ?? 0
        let buttonHeight = max(minHeight, shuffleLabelSize.height)
        shuffleButton.frame = CGRect(x: view.frame.midX - (maxLabelWidth/2), y: view.frame.height - (safeAreaInsets.bottom + buttonHeight + (scene.footerHeight - buttonHeight)/2.0) , width:maxLabelWidth, height: max(minHeight, buttonHeight))
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
            
            // remove the wiggle if it exists
            swap.candyA.removeWiggle()
            swap.candyB.removeWiggle()
            
            level.performSwap(swap)
            scene?.animate(swap, completion: handleMatches)
        } else {
            scene?.animateInvalidSwap(swap) {
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
        scene?.animateMatchedCandies(for: chains, comboLevel: comboLevel) {
            for chain in chains {
                self.score += chain.score
                self.timeValueLabel.addTime(duration: chain.bonusTime)
            }
            
            let fallingColumns = self.level.fillHoles()
            let newColumns = self.level.topUpCookies()
            self.scene?.animate(fallingCandies: fallingColumns, newCandies: newColumns) {
                self.handleMatches(comboLevel: comboLevel + 1)
            }
        }
    }

    private func updateLabels() {
        self.scoreValueLabel.text = numberFormatter.string(from: NSNumber(value: score))
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        while level.possibleSwaps.count == 0 {
            shuffle()
            wiggleShuffle()
        }
        restartHintTimer()
        view.isUserInteractionEnabled = true
    }
    
    func showGameOver() {
        scene?.gameOver()
        gameOverVC = GameOverViewController(score: score)
        gameOverVC.onDismissCompletion = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.beginGame()
        }
        gameOverVC.modalPresentationStyle = .overCurrentContext

        self.present(gameOverVC, animated: true, completion: nil)
    }
    
    func wiggleHint() {
        if (level.possibleSwaps.count > 0) {
            let swap = level.possibleSwaps.randomElement()
            swap?.candyA.wiggle()
            swap?.candyB.wiggle()
        } else {
            wiggleShuffle()
        }
    }

    func wiggleShuffle() {
        let wiggle = CABasicAnimation(keyPath: "transform.rotation")
        wiggle.fromValue = NSNumber(floatLiteral: -Double(CGFloat.pi / 36)) // 5 degrees each way
        wiggle.toValue = NSNumber(floatLiteral: Double(CGFloat.pi / 36))
        wiggle.duration = 0.15
        wiggle.autoreverses = true
        wiggle.repeatCount = 4
        wiggle.isRemovedOnCompletion = true
        shuffleButton.layer.add(wiggle, forKey: "wiggle")
    }
}

extension GameViewController : CountdownLabelDelegate {
    
    func countdownLabelDidExpire(_ countdownLabel: CountdownLabel) {
        // game over
        showGameOver()
    }
    
    func countdownLabel(_ countdownLabel: CountdownLabel, didChangeTo time: TimeInterval) {
        self.shuffleButton.isEnabled = time > abs(level.shufflePenalityTime)
    }
}

extension GameViewController : TitleSceneDelegate {
    
    func titleSceneShouldDismiss(_ titleScene: TitleScene) {
        setupGame()
        transition(to: scene!, fromScene: titleScene)
    }
    
}
