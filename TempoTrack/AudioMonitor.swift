//
//  AudioMonitor.swift
//  TempoTrack
//
//  Created by hxg on 2/9/25.
//

import AVFoundation
import SoundAnalysis
import CoreML

class AudioMonitor: NSObject, ObservableObject {
    private var audioEngine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private var analyzer: SNAudioStreamAnalyzer?
    private var request: SNClassifySoundRequest?
    
    @Published var detectedLabel: String = "Unknown"

    func startMonitoring() {
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { buffer, time in
                self.analyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }

            // Initialize Sound Analysis
            let model = try MySoundClassifier_1(configuration: MLModelConfiguration())
            request = try SNClassifySoundRequest(mlModel: model.model)
            analyzer = SNAudioStreamAnalyzer(format: recordingFormat)
            
            try analyzer?.add(request!, withObserver: self)

            try audioEngine.start()
        } catch {
            print("Error setting up audio monitoring: \(error)")
        }
    }

    func stopMonitoring() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

// MARK: - Handle Sound Classification
extension AudioMonitor: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else { return }
        
        DispatchQueue.main.async {
            self.detectedLabel = classification.identifier // "Piano" or "Non-Piano"
            print("Detected: \(self.detectedLabel)")
        }
    }
}
