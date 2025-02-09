//
//  PianoTimerViewModel.swift
//  TempoTrack
//
//  Created by hxg on 2/9/25.
//

import Combine
import Foundation

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = 60 // For example, 60 seconds
    @Published var isPianoPlaying: Bool = false

    private var cancellables = Set<AnyCancellable>()
    var audioMonitor = AudioMonitor()
    
    // Timer
    private var timer: Timer?

    init() {
        audioMonitor.$currentAmplitude
            .receive(on: RunLoop.main)
            .sink { [weak self] amplitude in
                self?.updatePianoState(amplitude: amplitude)
            }
            .store(in: &cancellables)
    }
    
    func start() {
        audioMonitor.startMonitoring()
        startCountdownIfNeeded()
    }
    
    func stop() {
        audioMonitor.stopMonitoring()
        stopCountdown()
    }
    
    private func updatePianoState(amplitude: Float) {
        // Simple threshold logic:
        let threshold: Float = -40.0
        if amplitude > threshold {
            // Piano is playing
            if !isPianoPlaying {
                isPianoPlaying = true
                // Resume countdown
                startCountdownIfNeeded()
            }
        } else {
            // Possibly silent
            if isPianoPlaying {
                // Optional: Confirm silent for a few consecutive checks
                // to avoid false positives from short pauses
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // Double-check amplitude again, or keep a short buffer
                    if self.audioMonitor.currentAmplitude <= threshold {
                        self.isPianoPlaying = false
                        self.stopCountdown()
                    }
                }
            }
        }
    }
    
    private func startCountdownIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard self.timeRemaining > 0 else {
                // Timer done
                self.stopCountdown()
                return
            }
            self.timeRemaining -= 1
        }
    }
    
    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
}
