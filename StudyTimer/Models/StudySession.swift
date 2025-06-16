//
//  StudySession.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import Foundation
import SwiftData

@Model // Step 1
final class StudySession: Identifiable {
    let id: String  = UUID().uuidString
    let creationDate = Date()
    let duration: Int
    let subject: String
    let topic: String
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
