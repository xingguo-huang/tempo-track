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
                Text("Piano is \(viewModel.isPianoPlaying ? "playing" : "silent")")
                    .font(.title2)
                
                HStack {
                    Button("Start") {
                        viewModel.start()
                    }
                    Button("Stop") {
                        viewModel.stop()
                    }
                }
            }
            .padding()
        }
}

#Preview {
    ContentView()
}
