//
//  CountdownLabel.swift
//  Match3
//
//  Created by emma herold on 7/12/21.
//

import SpriteKit

class CountdownLabel: SKLabelNode {
    
    var endTime:Date!
    
    func addTime(duration: TimeInterval){
        endTime = endTime.addingTimeInterval(duration)
    }
    
    func update(){
        let timeLeftInteger = Int(timeLeft())
        if (timeLeftInteger >= 0) {
            text = secondsIntoTimeRemaining(seconds:timeLeftInteger)
        }
    }
    
    func startWithDuration(duration: TimeInterval){
        let timeNow = Date()
        endTime = timeNow.addingTimeInterval(duration)
    }

    func hasFinished() -> Bool{
        return timeLeft() == 0
    }

    private func timeLeft() -> TimeInterval{
        let now = Date();
        let remainingSeconds = endTime.timeIntervalSince(now)
        return max(remainingSeconds, 0)
    }
    
    private func secondsIntoTimeRemaining(seconds: Int) -> String{
        var result = ""
        result.append(String(seconds / 60))
        result.append(":")
        
        let remainingSeconds = seconds % 60
        if (remainingSeconds < 10) {
            result.append("0") // 1:08 instead of 1:8
        }
        result.append(String(remainingSeconds))
        
        return result
    }
}
