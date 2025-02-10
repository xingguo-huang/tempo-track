//
//  AudioMonitor.swift
//  TempoTrack
//
//  Created by hxg on 2/9/25.
//

import SwiftUI
import AVFoundation

class AudioMonitor: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private var isMonitoring = false // ✅ Prevent multiple taps

    @Published var currentAmplitude: Float = 0.0

    func startMonitoring() {
        guard !isMonitoring else { return } // ✅ Prevent multiple starts
        isMonitoring = true
        
        // Configure audio session
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // ✅ Remove existing tap before adding a new one
        inputNode.removeTap(onBus: 0)
        
        // Install a tap on the input node
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer: buffer)
        }

        // Start the engine
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return } // ✅ Prevent stopping if already stopped
        isMonitoring = false
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }

    private func processAudioBuffer(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else {
            return
        }
        // `frameLength` is how many audio frames are in this buffer
        let frameLength = Int(buffer.frameLength)

        // Calculate RMS (Root Mean Square) or a basic amplitude
        var sum: Float = 0.0
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        let rms = sqrt(sum / Float(frameLength))
        
        // Convert RMS to dB (Optional if you want dB scale)
        let amplitude = 20.0 * log10(rms)
        
        // Update a published property so UI can react
        DispatchQueue.main.async {
            self.currentAmplitude = amplitude.isNaN ? -160.0 : amplitude
        }
        print("Current Amplitude: \(self.currentAmplitude) dB")
    }
}
