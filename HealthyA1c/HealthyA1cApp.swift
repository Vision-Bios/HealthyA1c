//
//  HealthyA1cApp.swift
//  HealthyA1c
//
//  Created by Mohamad Alayouni on 1/20/26.
//

import SwiftUI
import UIKit
import AudioToolbox

@main
struct HealthyA1cApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

@MainActor
final class FunFeedback {
    static let shared = FunFeedback()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let notify = UINotificationFeedbackGenerator()

    func tap() {
        lightImpact.impactOccurred()
        play(sound: 1104)
    }

    func success() {
        notify.notificationOccurred(.success)
        play(sound: 1113)
    }

    func warning() {
        notify.notificationOccurred(.warning)
        play(sound: 1053)
    }

    func heavyPulse() {
        mediumImpact.impactOccurred()
        play(sound: 1109)
    }

    private func play(sound: SystemSoundID) {
        AudioServicesPlaySystemSound(sound)
    }
}
