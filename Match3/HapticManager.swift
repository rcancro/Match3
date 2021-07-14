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
    private func buzzPattern(comboLevel: Int) throws -> CHHapticPattern {
        let comboMinPercent = Double(0.5)
        let level = Double(comboLevel >= SKAction.maxComboLevel ? SKAction.maxComboLevel - 1 : comboLevel)
        let comboRelative = (level / Double(SKAction.maxComboLevel)) * (1.0 - comboMinPercent)
        let comboPercent = comboRelative + comboMinPercent
        let rumble = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
            ],
            relativeTime: 0,
            duration: 0.6)
        
        let buzz = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.08,
            duration: 0.5 * comboPercent)
        return try CHHapticPattern(events: [rumble, buzz], parameters: [])
    }
    private func playHapticFromPattern(_ pattern: CHHapticPattern) throws {
        try hapticEngine.start()
        let player = try hapticEngine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    }
    func playCombo(comboLevel: Int) {
        do {
            let pattern = try buzzPattern(comboLevel: comboLevel)
            try playHapticFromPattern(pattern)
        } catch {
            print("Failed to play slice: \(error)")
        }
    }
}
