//
//  TimerCountdownView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/15/25.
//

import SwiftUI
import Combine

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
                .foregroundColor(viewModel.progressColor)
                .rotationEffect(.degrees(-90))
            
            Text(viewModel.timeString)
                .font(.system(size: 30, weight: .semibold, design: .monospaced))
                .foregroundColor(viewModel.progressColor)
        }
        .frame(width: 150, height: 150)
        .onReceive(timer) { _ in
            viewModel.tick()
        }
    }
}

extension TimerCountdownView {
    final class ViewModel: ObservableObject {
        internal var isRunning: Bool = false
        let totalTime: Int
        @Published var remainingTime: Int
        var completedSubject: PassthroughSubject<Void, Never> = .init()

        init(totalTime: Int){
            self.totalTime = totalTime
            self.remainingTime = totalTime
        }
        
        var progress: CGFloat {
            CGFloat(totalTime - remainingTime) / CGFloat(totalTime)
        }
        
        var timeString: String {
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
        var progressColor: Color {
            var opacityValue: CGFloat = 0.0
            if progress <= 0.25 {
                opacityValue = 0.25
            } else if progress <= 0.5 {
                opacityValue = 0.5
            } else if progress <= 0.75 {
                opacityValue = 0.75
            } else {
                opacityValue = 1.0
            }
            return .cardBackground.opacity(opacityValue)
        }

        
        func start() {
            isRunning = true
        }
        
        func stop() {
            isRunning = false
        }
        
        func reset() {
            remainingTime = totalTime
        }
        
        func tick() {
            guard isRunning,
                  remainingTime > 0
            else {
                return
            }
            remainingTime -= 1
            if remainingTime == 0 {
                isRunning = false
                completedSubject.send(())
            }
        }

    }
}
