//
//  StudySession.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import Foundation
// Step 1
import SwiftData

@Model // Step 2
final class StudySession: Identifiable {
    internal var id: String  = UUID().uuidString
    var creationDate = Date()
    var duration: Int
    var subject: String
    var topic: String
    
    var durationInSeconds: Int {
        return duration * 60
    }
    init(
        duration: Int,
        subject: String,
        topic: String
    ) {
        self.duration = duration
        self.subject = subject
        self.topic = topic
    }
}
