//
//  SKAction+Sounds.swift
//  Match3
//
//  Created by Doug Pedley on 7/13/21.
//

import SpriteKit

extension SKAction {
    static let burstAudioActions = [
        SKAction.playSoundFileNamed("impactMetal_light_000", waitForCompletion: false),
        SKAction.playSoundFileNamed("impactMetal_light_001", waitForCompletion: false),
        SKAction.playSoundFileNamed("impactMetal_light_002", waitForCompletion: false),
        SKAction.playSoundFileNamed("impactMetal_light_003", waitForCompletion: false),
        SKAction.playSoundFileNamed("impactMetal_light_004", waitForCompletion: false)
    ]

    static var randomBurstSound: SKAction {
        guard let randomSoundAction = Self.burstAudioActions.randomElement() else {
            fatalError("Audio files not setup properly.")
        }
        return randomSoundAction
    }
}
