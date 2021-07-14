//
//  HapticManager.swift
//  Match3
//
//  Created by Doug Pedley on 7/14/21.
//

import SpriteKit
import CoreHaptics

class HapticManager {
    let hapticEngine: CHHapticEngine
    init?() {
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        guard hapticCapability.supportsHaptics else {
            return nil
        }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine.start()
            hapticEngine.isAutoShutdownEnabled = true
        } catch let error {
            print("Haptic engine error: \(error)")
            return nil
        }
    }
}

extension HapticManager {
    private func buzzPattern(comboPercent: Float) throws -> CHHapticPattern {
        let rumble = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7 * comboPercent),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
            ],
            relativeTime: 0,
            duration: 0.6 * Double(comboPercent))
        
        let buzz = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: comboPercent),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.08,
            duration: 0.2 * Double(comboPercent))
        
        return try CHHapticPattern(events: [rumble, buzz], parameters: [])
    }
    private func playHapticFromPattern(_ pattern: CHHapticPattern) throws {
        try hapticEngine.start()
        let player = try hapticEngine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    }
    func playCombo(comboLevel: Int) {
        do {
            let comboMinPercent = Float(0.5)
            let level = Float(comboLevel >= SKAction.maxComboLevel ? SKAction.maxComboLevel - 1 : comboLevel)
            let comboRelative: Float = (Float(level) / Float(SKAction.maxComboLevel)) * (1.0 - comboMinPercent)
            let pattern = try buzzPattern(comboPercent: comboRelative + comboMinPercent)
            try playHapticFromPattern(pattern)
        } catch {
            print("Failed to play slice: \(error)")
        }
    }
}
