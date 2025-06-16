//
//  CreateSessionView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import SwiftUI
import SwiftData

struct CreateSessionView: View {
    @ObservedObject var viewModel: ViewModel
    @State var showSubjectSelectionView = false
    @State var showTopicSelectionView = false
    @State var showTimerOptionsView = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let timerVM = viewModel.timerViewModel {
                TimerCountdownView(
                    viewModel: timerVM
                    )
                .padding(.top, 10)
            } else {
                Image(.appLogo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(20)
                    .padding(.top, 10)
            }
            Text(viewModel.studyTimerText)
                .font(.system(size: 50, weight: .semibold))
                .foregroundColor(.buttonTitleText)
                .padding(.top, 10)
            
            InfoRowView(viewModel: .init(
                title: "Duration",
                value: viewModel.durationText,
                valueBackgroundColor: .clear,
                titleTintColor: .buttonTitleText,
                valueTintColor: .buttonTitleText,
                onTap: {
                    showTimerOptionsView.toggle()
                }
            )
            )
            .background(Color.durationBackground)
            .cornerRadius(20)
            
            VStack {
                InfoRowView(viewModel: .init(
                    title: "Subject",
                    value: viewModel.subjectText,
                    valueBackgroundColor: .pillBackground,
                    titleTintColor: .screenBackground,
                    valueTintColor: .pillText,
                    onTap: {
                        viewModel.selectedTopic = nil
                        showSubjectSelectionView.toggle()
                    }
                )
                )
                Divider().padding(.horizontal, 20)
                InfoRowView(viewModel: .init(
                    title: "Topic",
                    value: viewModel.topicText,
                    valueBackgroundColor: .pillBackground,
                    titleTintColor: .screenBackground,
                    valueTintColor: .pillText,
                    onTap: {
                        guard viewModel.selectedSubject != nil else { return }
                        showTopicSelectionView.toggle()
                    }
                )
                )
            }
            .background(Color.cardBackground)
            .cornerRadius(20)
            Text(viewModel.prompt)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.buttonTitleText)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            
            Button {
                viewModel.handleStartSessionTapped()
            } label: {
                Text(viewModel.studySessionState.buttonTitle)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color.cardBackground)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.studySessionState.buttonBackgroundColor)
                    .cornerRadius(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .background(Color.screenBackground)
        .ignoresSafeArea()
        .sheet(isPresented: $showSubjectSelectionView) {
            SelectionView(viewModel: .init(title: "Select Subject", options: viewModel.subjects), selectedOption: $viewModel.selectedSubject)
        }
        
        .sheet(isPresented: $showTopicSelectionView) {
            SelectionView(viewModel: .init(title: "Select Topic", options: viewModel.topicsInSelectedSubject), selectedOption: $viewModel.selectedTopic)
        }
        .sheet(isPresented: $showTimerOptionsView) {
            SelectionView(viewModel: .init(title: "Select Duration", options: viewModel.durationsInMinutes), selectedOption: $viewModel.selectedDuration)
        }
    }
}
