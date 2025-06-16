//
//  TimerCountdownView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/15/25.
//

import SwiftUI

struct TimerCountdownView: View {
    @ObservedObject var viewModel: ViewModel
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.2)
                .foregroundColor(Color.cardBackground)
            
            Circle()
                .trim(from: 0.0, to: viewModel.progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundColor(.cardBackground)
                .rotationEffect(.degrees(-90))
            
            Text(viewModel.timeString)
                .font(.system(size: 30, weight: .semibold, design: .monospaced))
        }
        .frame(width: 150, height: 150)
        .onReceive(timer) { _ in
            viewModel.tick()
        }
    }
}

extension TimerCountdownView {
    final class ViewModel: ObservableObject {
        @Published var remainingTime: Int
        @Published var isRunning: Bool = false
        let totalTime: Int

        init(totalTime: Int,
             isRunning: Bool = false
        ){
            self.totalTime = totalTime
            self.remainingTime = totalTime
            self.isRunning = isRunning
        }

        func tick() {
            if isRunning && remainingTime > 0 {
                remainingTime -= 1
            }
        }

        var progress: CGFloat {
            CGFloat(totalTime - remainingTime) / CGFloat(totalTime)
        }

        var timeString: String {
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
