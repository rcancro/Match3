//
//  GameOverViewController.swift
//  Match3
//
//  Created by emma herold on 7/14/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameOverViewController: UIViewController {

    var gameOverScene: GameOverScene!
    
    var score : Int
    
    var onDismissCompletion: ()->Void = {}
    
    var gameOverTitleLabel = UILabel()
    var scoreTitleLabel = UILabel()
    var scoreValueLabel = UILabel()
    var highScoresTitleLabel = UILabel()
    var highScoresTable : HighScoresView
    var tryAgainTitleLabel = UILabel()
    var tryAgainYesButton = UIButton()
    var tryAgainNoButton = UIButton()
    var shareYourScoreButton = UIButton()
    
    var dummyHighScoresData = [(7001234, "EMMA HEROLD", false), (500, "RICKYCANCRO", false), (500, "DOUG PEDLEY", false)]
    
    var skView: SKView!
    
    init(score: Int) {
        self.score = score
        self.highScoresTable = HighScoresView(currentUserScore: score, highScoresArray: dummyHighScoresData)
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.backgroundColor = .green
        skView.isMultipleTouchEnabled = false
        view.addSubview(skView)
        
        gameOverTitleLabel.font = UIFont.customFont(ofSize: 60)
        view.addSubview(gameOverTitleLabel)
        gameOverTitleLabel.adjustsFontSizeToFitWidth = true
        gameOverTitleLabel.text = "GAME OVER"
        gameOverTitleLabel.textAlignment = .center
        gameOverTitleLabel.textColor = .halloweenYellowGreen
        
        scoreTitleLabel.font = UIFont.customFont(ofSize: 18)
        view.addSubview(scoreTitleLabel)
        scoreTitleLabel.adjustsFontSizeToFitWidth = true
        scoreTitleLabel.text = "SCORE"
        scoreTitleLabel.textAlignment = .center
        scoreTitleLabel.textColor = .halloweenPurple
        
        scoreValueLabel.font = UIFont.customFont(ofSize: 32)
        view.addSubview(scoreValueLabel)
        scoreValueLabel.adjustsFontSizeToFitWidth = true
        scoreValueLabel.text = numberFormatter.string(from: NSNumber(value: score))
        scoreValueLabel.textAlignment = .center
        scoreValueLabel.textColor = .halloweenYellowGreen
        
        highScoresTitleLabel.font = UIFont.customFont(ofSize: 18)
        view.addSubview(highScoresTitleLabel)
        highScoresTitleLabel.adjustsFontSizeToFitWidth = true
        highScoresTitleLabel.text = "HIGH SCORES"
        highScoresTitleLabel.textAlignment = .center
        highScoresTitleLabel.textColor = .halloweenPurple
        
        view.addSubview(highScoresTable)
        
        tryAgainTitleLabel.font = UIFont.customFont(ofSize: 36)
        view.addSubview(tryAgainTitleLabel)
        tryAgainTitleLabel.adjustsFontSizeToFitWidth = true
        tryAgainTitleLabel.text = "TRY AGAIN?"
        tryAgainTitleLabel.textAlignment = .center
        tryAgainTitleLabel.textColor = .halloweenYellowGreen
        
        tryAgainYesButton = UIButton(type: .system)
        view.addSubview(tryAgainYesButton)
        tryAgainYesButton.setTitle("      YES      ", for: .normal)
        tryAgainYesButton.titleLabel?.font = UIFont.customFont(ofSize: 24)
        tryAgainYesButton.setTitleColor(.white, for: .normal)
        tryAgainYesButton.backgroundColor = .halloweenPink
        tryAgainYesButton.addTarget(self, action: #selector(handleTryAgainYesButtonTapped), for: .touchUpInside)
        
        tryAgainNoButton = UIButton(type: .system)
        view.addSubview(tryAgainNoButton)
        tryAgainNoButton.setTitle("      NO      ", for: .normal)
        tryAgainNoButton.titleLabel?.font = UIFont.customFont(ofSize: 24)
        tryAgainNoButton.setTitleColor(.white, for: .normal)
        tryAgainNoButton.backgroundColor = .halloweenPink
        tryAgainNoButton.addTarget(self, action: #selector(handleTryAgainNoButtonTapped), for: .touchUpInside)
        
        shareYourScoreButton = UIButton(type: .system)
        view.addSubview(shareYourScoreButton)
        shareYourScoreButton.setTitle("  SHARE YOUR SCORE  ", for: .normal)
        shareYourScoreButton.titleLabel?.font = UIFont.customFont(ofSize: 24)
        shareYourScoreButton.setTitleColor(.white, for: .normal)
        shareYourScoreButton.backgroundColor = .halloweenPink
        shareYourScoreButton.addTarget(self, action: #selector(handleShareYourScorebuttonTapped), for: .touchUpInside)
        
        // Prep the game over page
        gameOverScene = GameOverScene(size: skView.bounds.size)
        gameOverScene.backgroundColor = UIColor.purple

        // Present the scene.
        skView.presentScene(gameOverScene)
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
        let xMargins: CGFloat = 22
        let maxLabelWidth = ceil(view.frame.width * 0.5) - xMargins
        let maxSize = CGSize(width: view.frame.width, height: 80000)
        
        // Game over and score
        let gameOverTitleSize = gameOverTitleLabel.sizeThatFits(maxSize)
        gameOverTitleLabel.frame = CGRect(x: view.frame.midX - (maxLabelWidth / 2), y: 70, width: maxLabelWidth, height: gameOverTitleSize.height)
        
        let paddingBeforeScore : CGFloat = 0.0
        
        let scoreTitleSize = scoreTitleLabel.sizeThatFits(maxSize)
        scoreTitleLabel.frame = CGRect(x: view.frame.midX - (maxLabelWidth / 2), y: gameOverTitleLabel.frame.maxY + paddingBeforeScore, width: maxLabelWidth, height: scoreTitleSize.height)
        
        let scoreValueNegativePadding : CGFloat = -8.0
        let scoreValueSize = scoreValueLabel.sizeThatFits(maxSize)
        scoreValueLabel.frame = CGRect(x: view.frame.midX - (maxLabelWidth / 2), y: scoreTitleLabel.frame.maxY + scoreValueNegativePadding, width: maxLabelWidth, height: scoreValueSize.height)
        
        // High scores
        let highScoresTitleSize = highScoresTitleLabel.sizeThatFits(maxSize)
        highScoresTitleLabel.frame = CGRect(x: view.frame.midX - (maxLabelWidth / 2), y: 280, width: maxLabelWidth, height: highScoresTitleSize.height)
        
        let tableTopPadding : CGFloat = 8.0
        let tableSidePadding : CGFloat = 60.0
        let tableHeight : CGFloat = 100
        let tableWidth : CGFloat = maxSize.width - (tableSidePadding * 2)
        highScoresTable.frame = CGRect(x: view.frame.midX - (tableWidth / 2), y: highScoresTitleLabel.frame.maxY + tableTopPadding, width: tableWidth, height: tableHeight)
        
        // Try again?
        let tryAgainTitleSize = scoreValueLabel.sizeThatFits(maxSize)
        let verticalButtonSpacing : CGFloat = 12.0
        let bottomButtonStartingY: CGFloat = view.frame.maxY - (3 * tryAgainTitleSize.height) - (3 * verticalButtonSpacing)
        tryAgainTitleLabel.frame = CGRect(x: view.frame.midX - (maxLabelWidth / 2), y: bottomButtonStartingY, width: maxLabelWidth, height: tryAgainTitleSize.height)
        
        let buttonWidth : CGFloat = 60.0
        let buttonSpacing : CGFloat = 8.0
        
        let tryAgainButtonSize = tryAgainYesButton.sizeThatFits(CGSize(width: buttonWidth, height: maxSize.height))
        tryAgainYesButton.frame = CGRect(x:view.frame.midX - tryAgainButtonSize.width - (buttonSpacing/2.0), y: tryAgainTitleLabel.frame.maxY + verticalButtonSpacing, width: tryAgainButtonSize.width, height:tryAgainButtonSize.height)
        tryAgainNoButton.frame = CGRect(x:view.frame.midX + (buttonSpacing/2.0), y: tryAgainTitleLabel.frame.maxY + verticalButtonSpacing, width: tryAgainButtonSize.width, height:tryAgainButtonSize.height)
        
        let shareYourScoreButtonWidth = tryAgainNoButton.frame.maxX - tryAgainYesButton.frame.minX
        let shareYourScoreButtonSize = CGSize(width: shareYourScoreButtonWidth, height: shareYourScoreButton.sizeThatFits(maxSize).height)
        shareYourScoreButton.frame = CGRect(x: view.frame.midX - (shareYourScoreButtonSize.width / 2.0), y: tryAgainYesButton.frame.maxY + verticalButtonSpacing, width: shareYourScoreButtonSize.width, height: shareYourScoreButtonSize.height)
        
    }
    
    @objc func handleTryAgainYesButtonTapped() {
        self.dismiss(animated: true, completion: onDismissCompletion)
    }
    
    @objc func handleTryAgainNoButtonTapped() {
        // TODO: Exit the game
        self.dismiss(animated: true, completion: onDismissCompletion)
    }
    
    @objc func handleShareYourScorebuttonTapped() {
        let shareText = "I scored \(score) in the Pinterest candy match game!"
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
