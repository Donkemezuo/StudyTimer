//
//  CreateSessionView + Extension.swift
//  StudyTimer
//
//  Created by Raymond Donkemezuo on 6/16/25.
//
import SwiftUI
import Combine

extension CreateSessionView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var selectedSubject: String? = nil
        @Published var selectedTopic: String? = nil
        @Published var selectedDuration: Int? = nil
        @Published var studySession: StudySession? = nil
        @Published var timerViewModel: TimerCountdownView.ViewModel? = nil
        @Published var studySessionState: StudySessionState = .new
        private let dataManager: SwiftDataManaging
        var cancellables: Set<AnyCancellable> = []
        
        init(
            studySession: StudySession? = nil,
            dataManager: SwiftDataManaging
        ) {
            self.studySession = studySession
            self.dataManager = dataManager
            self.selectedSubject = studySession?.subject
            self.selectedDuration = studySession?.duration
            self.selectedTopic = studySession?.topic
            self.fetchLatestStudySession()
            if let duration = duration,
               timerViewModel == nil
            {
                self.timerViewModel = .init(totalTime: duration)
                self.bindTimerCompletion()
            }
            dataManager
                .didSaveNewSessionSubject
                .receive(on: RunLoop.main)
                .sink {[weak self] in
                    guard let self else { return }
                    self.fetchLatestStudySession()
                    self.startStudySession()
                }.store(in: &cancellables)
        }
        
        var durationText: String {
            if let selectedDuration {
                return String(describing: selectedDuration) + " min"
            }  else {
                return "Select"
            }
        }
        
        var topicText: String {
            if let selectedTopic {
                return selectedTopic
            }  else {
                return "Select"
            }
        }
        
        var subjectText: String {
            if let selectedSubject {
                return selectedSubject
            }  else {
                return "Select"
            }
        }
        
        var studyTimerText: String {
            return "Study Timer"
        }
        
        var prompt: String {
            switch studySessionState {
            case .stopped:
                return "Resume your \(studySession?.duration ?? 0)-minute study session on \(studySession?.subject ?? "subject")"
            case .running:
                return "Stop your \(studySession?.duration ?? 0)-minute study session on \(studySession?.subject ?? "subject")"
            case .new:
                return "Start a study session"
            }
        }
        
        var duration: Int? {
            var value: Int?
            if let studySession {
                value  =  studySession.duration * 60
            } else if let selectedDuration {
                value = selectedDuration * 60
            } else {
                value = nil
            }
            return value
        }
        
        @MainActor
        private func startStudySession() {
            guard let duration else { return }
            timerViewModel = .init(totalTime: duration)
            timerViewModel?.start()
            studySessionState = .running
            bindTimerCompletion()
        }
        
        private func stopStudySession() {
            timerViewModel?.stop()
            studySessionState = .stopped
        }
        
        private func resumeExistingSession() {
            guard let session = studySession else { return }
            if timerViewModel == nil {
                timerViewModel = .init(totalTime: session.duration * 60)
                bindTimerCompletion()
            }
            timerViewModel?.start()
            studySessionState = .running
        }
        
        func handleStartSessionTapped() {
            switch studySessionState {
            case .stopped:
                resumeExistingSession()
            case .running:
                stopStudySession()
            case .new:
                Task {
                    try await createStudySession()
                }
            }
        }
        
       private func createStudySession() async throws {
            guard let selectedSubject,
                  let selectedTopic,
                  let selectedDuration else {
                return
            }
            let newStudySession = StudySession(
                duration: selectedDuration,
                subject: selectedSubject,
                topic: selectedTopic
            )
           try dataManager.saveSession(newStudySession)
        }
    
        private func bindTimerCompletion() {
            timerViewModel?.completedSubject
                .receive(on: RunLoop.main)
                .sink { [weak self] in
                    self?.studySessionState = .new
                }.store(in: &cancellables)
            
        }
        private func fetchLatestStudySession() {
            if timerViewModel != nil {
                timerViewModel = nil
            }
            Task {
                do {
                    studySession = try dataManager.fetchLatestStudySession()
                } catch {
                    print("Error fetching latest study session: \(error)")
                }
            }
        }
        
        let subjects = [
            "Mathematics",
            "Biology",
            "Chemistry",
            "Physics",
            "Computer Science",
            "English Language",
            "English Literature",
            "History",
            "Geography",
            "Economics",
            "Psychology",
            "Sociology",
            "Political Science",
            "Philosophy",
            "French",
            "Spanish",
            "Art History",
            "Music Theory",
            "Business Studies",
            "Accounting",
            "Marketing",
            "Personal Finance",
            "Health Education",
            "Physical Education",
            "Creative Writing",
            "Environmental Science"
        ]
        
        private let subjectTopics: [String: [String]] = [
            "Mathematics": ["Algebra", "Geometry", "Calculus", "Statistics", "Trigonometry"],
            "Biology": ["Cell Biology", "Genetics", "Human Anatomy", "Ecology", "Evolution"],
            "Chemistry": ["Organic Chemistry", "Inorganic Chemistry", "Stoichiometry", "Periodic Table", "Chemical Reactions"],
            "Physics": ["Mechanics", "Optics", "Electricity and Magnetism", "Thermodynamics", "Quantum Physics"],
            "Computer Science": ["Data Structures", "Algorithms", "Web Development", "Programming in Swift", "Databases"],
            "English Language": ["Grammar", "Vocabulary", "Comprehension", "Essay Writing", "Speech"],
            "English Literature": ["Shakespeare", "Poetry Analysis", "Modern Novels", "Drama", "Literary Devices"],
            "History": ["World War I", "World War II", "Cold War", "Ancient Civilizations", "Modern History"],
            "Geography": ["Physical Geography", "Human Geography", "Map Skills", "Climate", "Urbanization"],
            "Economics": ["Microeconomics", "Macroeconomics", "Supply and Demand", "Market Structures", "Global Economy"],
            "Psychology": ["Cognitive Psychology", "Behavioral Psychology", "Developmental Psychology", "Research Methods"],
            "Sociology": ["Culture", "Socialization", "Social Inequality", "Family Structures", "Education"],
            "Political Science": ["Governance", "Political Theories", "International Relations", "Elections", "Constitutions"],
            "Philosophy": ["Ethics", "Logic", "Existentialism", "Epistemology", "Political Philosophy"],
            "French": ["Grammar", "Vocabulary", "Speaking Practice", "Writing Practice", "Listening Comprehension"],
            "Spanish": ["Grammar", "Vocabulary", "Speaking Practice", "Reading Practice", "Tenses"],
            "Art History": ["Renaissance Art", "Modern Art", "Impressionism", "Sculpture", "Iconography"],
            "Music Theory": ["Chords", "Scales", "Harmony", "Sight Reading", "Composition"],
            "Business Studies": ["Entrepreneurship", "Business Models", "Operations", "Finance", "Marketing"],
            "Accounting": ["Bookkeeping", "Balance Sheets", "Income Statements", "Auditing", "Cost Accounting"],
            "Marketing": ["Digital Marketing", "Consumer Behavior", "Market Research", "Branding", "SEO"],
            "Personal Finance": ["Budgeting", "Saving", "Investing", "Credit Scores", "Loans"],
            "Health Education": ["Nutrition", "Mental Health", "Substance Abuse", "Reproductive Health", "Diseases"],
            "Physical Education": ["Fitness Training", "Sports Rules", "Anatomy", "Stretching", "Cardio Workouts"],
            "Creative Writing": ["Storytelling", "Poetry", "Character Development", "Plot Structure", "Dialogue"],
            "Environmental Science": ["Climate Change", "Sustainability", "Ecosystems", "Pollution", "Renewable Energy"]
        ]
        
        var topicsInSelectedSubject: [String] {
            guard let selectedSubject,
                  let topics = subjectTopics[selectedSubject]
            else {
                return []
            }
            return topics
        }
        let durationsInMinutes = [30, 45, 60, 75, 90, 105, 120]
    }
    
    enum StudySessionState {
        case stopped
        case running
        case new
        
        var buttonTitle: String {
            switch self {
            case .stopped:
                return "Resume"
            case .running:
                return "Stop"
            case .new:
                return "Start"
            }
        }
        
        var buttonBackgroundColor: Color {
            switch self {
            case .stopped, .new:
                return .startButtonBackground
            case .running:
                return .red
            }
        }
    }
    
}
