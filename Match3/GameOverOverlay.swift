//
//  GameOverOverlay.swift
//  Match3
//
//  Created by emma herold on 7/12/21.
//

import SpriteKit

class GameOverOverlay: UIView {
    var gameOverLabel: UILabel = UILabel()
    var yourScoreLabel: UILabel = UILabel()
    var highScoresLabel: UILabel = UILabel()
    
    
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
        
        gameOverLabel.text = "Game over"
        gameOverLabel.font = UIFont(name: "Kenney-Future-Square", size: 30)
        gameOverLabel.textColor = SKColor.black
        gameOverLabel.frame = CGRect(x:40, y:60, width: 500, height: 100)
        addSubview(gameOverLabel)
        
        yourScoreLabel.text = "Your Score: " + String(self.score)
        yourScoreLabel.font = UIFont(name: "Kenney-Future-Square", size: 30)
        yourScoreLabel.textColor = SKColor.black
        yourScoreLabel.frame = CGRect(x:40, y:140, width: 500, height: 100)
        addSubview(yourScoreLabel)
        
        highScoresLabel.text = "High Scores"
        highScoresLabel.font = UIFont(name: "Kenney-Future-Square", size: 30)
        highScoresLabel.textColor = SKColor.black
        highScoresLabel.frame = CGRect(x:40, y:220, width: 500, height: 100)
        addSubview(highScoresLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
