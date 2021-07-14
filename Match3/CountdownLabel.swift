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
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCountdown() {
        if remainingTime > 0 {
            normalTextColor = textColor
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
                guard let strongSelf = self else { return }
                strongSelf.remainingTime = max(0, strongSelf.remainingTime - 1)
                strongSelf.updateText()
                strongSelf.delegate?.countdownLabel(strongSelf, didChangeTo: strongSelf.remainingTime)
                
                if strongSelf.remainingTime == 0 {
                    timer.invalidate()
                    strongSelf.delegate?.countdownLabelDidExpire(strongSelf)
                }
            })
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
