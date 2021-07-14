//
//  SKAction+Sounds.swift
//  Match3
//
//  Created by Doug Pedley on 7/13/21.
//

import SpriteKit

extension SKAction {
    static let burstAudioActions = [
        SKAction.playSoundFileNamed("combo1", waitForCompletion: false),
        SKAction.playSoundFileNamed("combo2", waitForCompletion: false),
        SKAction.playSoundFileNamed("combo3", waitForCompletion: false),
        SKAction.playSoundFileNamed("combo4", waitForCompletion: false),
        SKAction.playSoundFileNamed("combo5", waitForCompletion: false),
        SKAction.playSoundFileNamed("combo6", waitForCompletion: false),
    ]

    static var maxComboLevel: Int { burstAudioActions.count }
    static func burstSound(comboLevel: Int) -> SKAction {
        let level = comboLevel >= maxComboLevel ? maxComboLevel - 1 : comboLevel
        return burstAudioActions[level]
    }
}
