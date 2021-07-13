//
//  CountdownLabel.swift
//  Match3
//
//  Created by emma herold on 7/12/21.
//

import SpriteKit

protocol CountdownLabelDelegate : AnyObject {
    func countdownLabelDidExpire(_ countdownLabel: CountdownLabel) -> Void
}

class CountdownLabel: UILabel {
    
    private var remainingTime: TimeInterval = 0.0
    var maxTime: TimeInterval = 120
    var timeRunningOutColor: UIColor = .red
    weak var delegate: CountdownLabelDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCountdown() {
        if remainingTime > 0 {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
                guard let strongSelf = self else { return }
                strongSelf.remainingTime = max(0, strongSelf.remainingTime - 1)
                if strongSelf.remainingTime <= 10 {
                    strongSelf.textColor = strongSelf.timeRunningOutColor
                } else {
                    strongSelf.textColor = .white
                }
                
                strongSelf.updateText()
                strongSelf.bumpAnimation()
                
                if strongSelf.remainingTime == 0 {
                    timer.invalidate()
                    strongSelf.delegate?.countdownLabelDidExpire(strongSelf)
                }
            })
        }
    }
    
    func setTime(duration: TimeInterval){
        remainingTime = duration
        updateText()
    }

    func addTime(duration: TimeInterval){
        remainingTime = min(maxTime, remainingTime + duration)
        updateText()
        bumpAnimation()
    }
    
    func updateText() {
        text = "\(Int(remainingTime))"
    }

    
    func startWithDuration(duration: TimeInterval){
        remainingTime = duration
    }

    func hasFinished() -> Bool{
        return remainingTime == 0
    }

}

extension UILabel {
    
    func bumpAnimation() {
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        } completion: { finished in
            UIView.animate(withDuration: 0.15) {
                self.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }
        }
    }
}
