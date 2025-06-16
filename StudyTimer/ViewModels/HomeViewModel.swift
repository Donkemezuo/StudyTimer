//
//  HomeViewModel.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var studySession: StudySession
    @Published var isStudying: Bool = false
    private let dataManager: SwiftDataManaging
    
    init(
        studySession: StudySession,
        isStudying: Bool,
        dataManager: SwiftDataManaging
    ) {
        self.studySession = studySession
        self.isStudying = isStudying
        self.dataManager = dataManager
    }
    
    var durationValue: String {
        return "\(studySession.duration) min"
    }
    
    var subjectValue: String {
        return "\(studySession.subject)"
    }
    var startButtonText: String {
        return  isStudying ? "Stop Studying" : "Start Studying"
    }
    
    var studyTimerText: String {
        return "Study Timer"
    }
    
    var durationTitleText: String {
        return "Duration"
    }
    
    var subjectTitleText: String {
        return "Subject"
    }
    var prompt: String {
        isStudying ?
        "Stop your \(studySession.duration)-minute study session on \(studySession.subject)" :
        "Start a \(studySession.duration)-minute study session on \(studySession.subject)"
    }
    func startStudying() {
        isStudying = !isStudying
    }
    func createStudySession() {
        
        let newStudySession = StudySession(duration: studySession.duration, subject: studySession.subject, topic: studySession.topic)
        
    }
    
}
