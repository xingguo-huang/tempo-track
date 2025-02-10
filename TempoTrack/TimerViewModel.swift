//
//  PianoTimerViewModel.swift
//  TempoTrack
//
//  Created by hxg on 2/9/25.
//
import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = 1800 // Example: 30 mins
    @Published var isPianoPlaying: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    var audioMonitor = AudioMonitor()
    
    private var timer: Timer?
    private var isTimerRunning = false

    init() {
        audioMonitor.$detectedLabel
            .receive(on: RunLoop.main)
            .sink { [weak self] label in
                self?.updatePianoState(label: label)
            }
            .store(in: &cancellables)
    }
    
    func start() {
        audioMonitor.startMonitoring()
        isTimerRunning = true
    }
    
    func stop() {
        audioMonitor.stopMonitoring()
        stopCountdown()
        isTimerRunning = false
    }

    private func updatePianoState(label: String) {
        if label == "Piano" {
            if !isPianoPlaying {
                isPianoPlaying = true
                startCountdownIfNeeded()
            }
        } else {
            if isPianoPlaying {
                isPianoPlaying = false
                stopCountdown()
            }
        }
    }
    
    private func startCountdownIfNeeded() {
        guard timer == nil, isTimerRunning else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.timeRemaining > 0 else {
                self?.stopCountdown()
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
