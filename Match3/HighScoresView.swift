//
//  HighScore.swift
//  Match3
//
//  Created by emma herold on 7/12/21.
//

import SpriteKit

class HighScoresView: UIView {
    
    var currentUsersName: String = "You!"
    var currentUserScore: Int
    var highScoresArray: [(score: Int, name: String, isCurrentPlayer: Bool)]
    
    init(currentUserScore: Int, highScoresArray: [(score: Int, name: String, isCurrentPlayer: Bool)]) {
        self.currentUserScore = currentUserScore
        self.highScoresArray = highScoresArray
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        insertUserScore()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertUserScore() {
        highScoresArray.append((score: currentUserScore, name: currentUsersName, isCurrentPlayer: true))
        highScoresArray = highScoresArray.sorted(by: {$0.score > $1.score})
    }

    func configureSubviews() {
        let rowSpacing = 0.0
        let rowHeight = 20.0
        for (index, (score, name, iscurrentUser)) in highScoresArray.enumerated() {
            let rowY = (Double(index) * rowHeight) + rowSpacing
            // rank
            let rankLabel = UILabel()
            rankLabel.text = convertIndexToRank(index: index)
            rankLabel.font = UIFont.customFont(ofSize: 14)
            rankLabel.textColor = iscurrentUser ? .halloweenYellowGreen : .halloweenPink
            rankLabel.frame = CGRect(x:0, y:rowY, width: 40, height: rowHeight)
            addSubview(rankLabel)
            
            // score
            let scoreLabel = UILabel()
            scoreLabel.text = numberFormatter.string(from: NSNumber(value: score))
            scoreLabel.textAlignment = .right
            scoreLabel.font = UIFont.customFont(ofSize: 14)
            scoreLabel.textColor = iscurrentUser ? .halloweenYellowGreen : .halloweenPink
            scoreLabel.frame = CGRect(x: 60, y:rowY, width: 80, height: rowHeight)
            addSubview(scoreLabel)
            
            // name
            let nameSpacing = 10.0
            let nameLabel = UILabel()
            nameLabel.text = name
            nameLabel.font = UIFont.customFont(ofSize: 14)
            nameLabel.textColor = iscurrentUser ? .halloweenYellowGreen : .halloweenPink
            nameLabel.frame = CGRect(x: Double(scoreLabel.frame.maxX) + nameSpacing, y:rowY, width: 140, height: rowHeight)
            addSubview(nameLabel)
        }
    }
    
    func convertIndexToRank(index: Int) -> String {
        if (index == 0) {
            return "1st"
        } else if (index == 1) {
            return "2nd"
        } else if (index == 2) {
            return "3rd"
        } else if (index == 3) {
            return "4th"
        } else if (index == 4) {
            return "5th"
        } else {
            assert(false, "invalid rank")
            return "?th"
        }
    }
}
