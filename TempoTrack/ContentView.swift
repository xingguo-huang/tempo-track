//
//  ContentView.swift
//  TempoTrack
//
//  Created by hxg on 2/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var selectedDuration: Int = 1800 // Default 30 mins

    var body: some View {
        VStack(spacing: 20) {
            // Time Picker
            VStack {
                Text("Select Session Duration:")
                    .font(.headline)
                Picker("Session Time", selection: $selectedDuration) {
                    Text("5 min").tag(300)
                    Text("10 min").tag(600)
                    Text("20 min").tag(1200)
                    Text("30 min").tag(1800)
                    Text("60 min").tag(3600)
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(viewModel.isTimerRunning) // Disable when timer is running
            }
            
            // Countdown Timer
            Text("Time Remaining: \(viewModel.timeRemaining)")
                .font(.largeTitle)
                .opacity(viewModel.isPianoPlaying ? 1 : 0.3) // Dim when not active

            Text(viewModel.isPianoPlaying ? "🎵 Piano is playing" : "🔇 Silent")
                .font(.title2)
                .foregroundColor(viewModel.isPianoPlaying ? .green : .gray)

            HStack {
                Button("Start") {
                    viewModel.start(duration: selectedDuration)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())

                Button("Stop") {
                    viewModel.stop()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
