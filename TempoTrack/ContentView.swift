//
//  ContentView.swift
//  TempoTrack
//
//  Created by hxg on 2/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Time Remaining: \(viewModel.timeRemaining)")
                .font(.largeTitle)
                .opacity(viewModel.isPianoPlaying ? 1 : 0.3) // Dim when not active

            Text(viewModel.isPianoPlaying ? "🎵 Piano is playing" : "🔇 Silent")
                .font(.title2)
                .foregroundColor(viewModel.isPianoPlaying ? .green : .gray)

            HStack {
                Button("Start") {
                    viewModel.start()
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
