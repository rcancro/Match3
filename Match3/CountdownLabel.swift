//
//  CountdownLabel.swift
//  Match3
//
//  Created by emma herold on 7/12/21.
//

import SpriteKit

protocol CountdownLabelDelegate : AnyObject {
    func countdownLabelDidExpire(_ countdownLabel: CountdownLabel) -> Void
    func countdownLabel(_ countdownLabel: CountdownLabel, didChangeTo time: TimeInterval) -> Void
}

class CountdownLabel: UILabel {
    
    private var remainingTime: TimeInterval = 0.0
    var maxTime: TimeInterval = 120
    var timeRunningOutColor: UIColor = .halloweenRed
    weak var delegate: CountdownLabelDelegate?
    var normalTextColor: UIColor = .white
    var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCountdown(speedFactor: CGFloat = 1.0) {
        if remainingTime > 0 {
            normalTextColor = textColor
            timer = Timer.scheduledTimer(withTimeInterval: 1.0/Double(speedFactor), repeats: true, block: { [weak self] timer in
                guard let strongSelf = self else { return }
                strongSelf.timerAction()
            })
        }
    }
    
    private func timerAction() {
        remainingTime = max(0, remainingTime - 1)
        updateText()
        delegate?.countdownLabel(self, didChangeTo: self.remainingTime)
        
        if self.remainingTime == 0 {
            timer?.invalidate()
            timer = nil
            delegate?.countdownLabelDidExpire(self)
        }
    }
    
    func increaseSpeed(to: CGFloat, duration: TimeInterval) {
        if let timer = timer {
            timer.invalidate()
            startCountdown(speedFactor: to)
        }
    }
    
    func setTime(duration: TimeInterval){
        remainingTime = duration
        delegate?.countdownLabel(self, didChangeTo: remainingTime)
        updateText()
    }

    func addTime(duration: TimeInterval){
        remainingTime = min(maxTime, remainingTime + duration)
        delegate?.countdownLabel(self, didChangeTo: remainingTime)
        updateText()
    }
    
    func updateText() {
        if remainingTime > 10 {
            textColor = normalTextColor
        } else {
            textColor = timeRunningOutColor
        }
        text = "\(Int(remainingTime))"
    }


    func hasFinished() -> Bool{
        return remainingTime == 0
    }

}
