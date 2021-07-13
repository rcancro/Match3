//
//  GameOverOverlay.swift
//  Match3
//
//  Created by emma herold on 7/12/21.
//

import SpriteKit

class GameOverOverlay: UIView {
    var verticalSpacing = 80.0
    var highScoreSpacing = 40.0
    var gameOverLabel: UILabel = UILabel()
    var yourScoreLabel: UILabel = UILabel()
    var highScoresTitleLabel: UILabel = UILabel()
    var highScoresValues: [UILabel] = []
    var highScoresArray: [(score: Int, name: String)] = [(700, "Emma"), (500, "Ricky"), (500, "Doug")]
    
    private var _score: Int = 0
    var score: Int {
        get {
            return self._score
        }
        set {
            self._score = newValue
            yourScoreLabel.text = "Your Score: " + String(self._score)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 1, alpha: 0.9)
        configureSubviews()
    }
    
    func configureSubviews() {
        gameOverLabel.text = "Game over"
        gameOverLabel.font = UIFont(name: "Kenney-Future-Square", size: 30)
        gameOverLabel.textColor = SKColor.black
        gameOverLabel.frame = CGRect(x:40, y:verticalSpacing, width: 500, height: 100)
        addSubview(gameOverLabel)
        
        yourScoreLabel.text = "Your Score: " + String(self.score)
        yourScoreLabel.font = UIFont(name: "Kenney-Future-Square", size: 30)
        yourScoreLabel.textColor = SKColor.black
        yourScoreLabel.frame = CGRect(x:40, y:verticalSpacing*2, width: 500, height: 100)
        addSubview(yourScoreLabel)
        
        highScoresTitleLabel.text = "High Scores"
        highScoresTitleLabel.font = UIFont(name: "Kenney-Future-Square", size: 30)
        highScoresTitleLabel.textColor = SKColor.black
        highScoresTitleLabel.frame = CGRect(x:40, y:verticalSpacing*3, width: 500, height: 100)
        addSubview(highScoresTitleLabel)
        
        for (index, (score, name)) in highScoresArray.enumerated() {
            let tempHighScoreLabel = UILabel()
            tempHighScoreLabel.text = String(score) + "            " + name
            tempHighScoreLabel.font = UIFont(name: "Kenney-Future-Square", size: 20)
            tempHighScoreLabel.textColor = SKColor.black
            tempHighScoreLabel.frame = CGRect(x:40, y:verticalSpacing*4+(Double(index)*highScoreSpacing), width: 500, height: 80)
            addSubview(tempHighScoreLabel)
        }

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
