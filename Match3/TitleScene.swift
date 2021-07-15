//
//  TitleScene.swift
//  Match3
//
//  Created by Ricky Cancro on 7/14/21.
//

import SpriteKit

protocol TitleSceneDelegate : AnyObject {
    func titleSceneShouldDismiss(_ titleScene: TitleScene) -> Void
}

class TitleScene : SKScene {
    
    let backgrackgroundSprite1 = SKSpriteNode(imageNamed: "title-background")
    let backgrackgroundSprite2 = SKSpriteNode(imageNamed: "title-background")
    let pinny = Pinny()
    var emitters:[SKEmitterNode] = []
    let label1 = SKLabelNode()

    let gameLayer = SKNode()
    let nextButton = UIButton(type: .custom)
    weak var sceneDelegate: TitleSceneDelegate?
    
    
    override init(size: CGSize) {
        super.init(size: size)
        addChild(gameLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // preload sounds
        let _ = SKAction.leavesSound()
        
        backgrackgroundSprite1.anchorPoint = .zero
        backgrackgroundSprite2.anchorPoint = .zero
        
        backgrackgroundSprite1.position = CGPoint(x: 0, y: view.frame.height - backgrackgroundSprite1.frame.height)
        backgrackgroundSprite2.position = CGPoint(x: backgrackgroundSprite1.frame.width, y: view.frame.height - backgrackgroundSprite1.frame.height)
        gameLayer.addChild(backgrackgroundSprite1)
        gameLayer.addChild(backgrackgroundSprite2)

        let move1 = SKAction.move(by: CGVector(dx: -backgrackgroundSprite1.frame.width, dy: 0), duration: 7)
        let move2 = SKAction.move(by: CGVector(dx: backgrackgroundSprite1.frame.width, dy: 0), duration: 0)
        let repeatAction = SKAction.repeatForever(SKAction.sequence([move1, move2]))

        
        backgrackgroundSprite1.run(repeatAction)
        backgrackgroundSprite2.run(repeatAction)
        
        pinny.position = CGPoint(x: view.center.x, y: backgrackgroundSprite1.position.y)
        pinny.additionalAction = SKAction.run { [weak pinny] in
            guard let strongPinny = pinny else { return }
            if strongPinny.isBent() {
                strongPinny.run(SKAction.leavesSound())
            }
        }
        pinny.animate()
        addChild(pinny)
        
        label1.fontName = "Kenney-Mini-Square"
        
        let intro1Text = NSLocalizedString("ios_halloween_intro_text_1", value: "After a long successful night of trick-or-treating, Pinny decides to call it a night. When suddenly...", comment: "Text for the intro of the 2021 halloween game. Pinny is the name of the pin character")
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributedText = NSAttributedString(string: intro1Text, attributes: [.foregroundColor : UIColor.white, .font : UIFont.customFont(ofSize: 24), .paragraphStyle : paragraph])
        label1.attributedText = attributedText
        label1.alpha = 0
        label1.numberOfLines = 0
        label1.preferredMaxLayoutWidth = view.frame.width - 32
        
        
        addChild(label1)
        label1.run(.fadeIn(withDuration: 2))
        label1.position = CGPoint(x: view.center.x, y: pinny.frame.origin.y - label1.frame.height - 10)
        
        nextButton.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.titleLabel?.font = UIFont.customFont(ofSize: 24)
        nextButton.titleLabel?.textAlignment = .center
        nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        let buttonSize = nextButton.sizeThatFits(CGSize(width: label1.preferredMaxLayoutWidth, height: 80000))
        
        
        nextButton.frame = CGRect(x: (view.frame.width - buttonSize.width)/2.0, y: (view.frame.height - label1.position.y) + buttonSize.height/2.0 + 16, width: buttonSize.width, height: buttonSize.height)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    
    @objc func nextButtonTapped() {
        UIView.animate(withDuration: 1) {
            self.nextButton.alpha = 0.0
        }
        label1.run(.sequence([.fadeOut(withDuration: 1), .removeFromParent()]))
        
        pinny.run(.fadeOut(withDuration: 1)) {
            self.pinny.removeFromParent()
            self.run(.sequence([.wait(forDuration: 0.5), SKAction.run {
                self.trip()
            }]))
            
        }
    }
    
    @objc func playButtonTapped() {
        nextButton.removeFromSuperview()
        sceneDelegate?.titleSceneShouldDismiss(self)
    }
    
    private func trip() {
        
        self.backgrackgroundSprite1.removeAllActions()
        self.backgrackgroundSprite2.removeAllActions()
        
        nextButton.setTitle("PLAY", for: .normal)
        nextButton.alpha = 1.0
        
        let intro1Text = NSLocalizedString("ios_halloween_intro_text_1", value: "She tripped and all her candy fell to the ground!!!\n\nBut no need to worry, you can help her collect it!", comment: "More Text for the intro of the 2021 halloween game. Pinny is the name of the pin character")
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributedText = NSAttributedString(string: intro1Text, attributes: [.foregroundColor : UIColor.white, .font : UIFont.customFont(ofSize: 24), .paragraphStyle : paragraph])
        label1.attributedText = attributedText
        label1.alpha = 1.0
        addChild(label1)
        
        let buttonSize = nextButton.frame.size
        nextButton.frame = CGRect(x: (view!.frame.width - buttonSize.width)/2.0, y: (view!.frame.height - label1.position.y) + buttonSize.height/2.0 + 16, width: buttonSize.width, height: buttonSize.height)
        
        nextButton.removeTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)


        let fallingPinny = SKSpriteNode(imageNamed: "falling-pinny")
        fallingPinny.position = pinny.position
        self.addChild(fallingPinny)
        
        let bag = SKSpriteNode(imageNamed: "bag")
        let rotation = SKAction.rotate(byAngle: .pi, duration: 1)
        bag.run(.repeatForever(rotation))
        bag.position = CGPoint(x: pinny.position.x - 30, y: pinny.position.y + 60)
        self.addChild(bag)
        
        let imageNames = ["candy-corn",
                          "gummi-bear-green",
                          "mm-red",
                          "orange-pop",
                          "smarties",
                          "tootsie-roll"]
        for imageName in imageNames {
            let emitter = SKEmitterNode(fileNamed: "CandyEmitter.sks")!
            if let image = UIImage(named: imageName) {
                emitter.particleTexture = SKTexture(image: image)
                emitter.particleSize = image.size
                emitter.numParticlesToEmit /= imageNames.count
                emitter.particleBirthRate /= CGFloat(imageNames.count)
                emitters.append(emitter)
            }
        }
        
        for emitter in emitters {
            emitter.position = CGPoint(x: self.size.width/2.0, y: self.size.height)
            addChild(emitter)
        }
        
    }
}
