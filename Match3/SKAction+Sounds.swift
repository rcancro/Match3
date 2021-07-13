//
//  SKAction+Sounds.swift
//  Match3
//
//  Created by Doug Pedley on 7/13/21.
//

import SpriteKit

extension SKAction {
    static let burstAudioActions = [
        SKAction.playSoundFileNamed("impactGlass_light_004", waitForCompletion: false),
        SKAction.playSoundFileNamed("impactGlass_light_003", waitForCompletion: false),
        SKAction.playSoundFileNamed("impactGlass_light_002", waitForCompletion: false),
        SKAction.playSoundFileNamed("impactGlass_light_001", waitForCompletion: false)
    ]

    static func burstSound(comboLevel: Int) -> SKAction {
        let level = comboLevel >= burstAudioActions.count ? burstAudioActions.count - 1 : comboLevel
        return burstAudioActions[level]
    }
}
