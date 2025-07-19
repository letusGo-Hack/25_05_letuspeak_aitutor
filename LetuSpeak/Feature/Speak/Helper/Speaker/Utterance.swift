//
//  Utterance.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import Foundation

struct CustomUtterance: Sendable {
    var rate: Float
    var pitchMultiplier: Float
    var postUtteranceDelay: Double
    var volume: Float
    var voice: Voice
    
    init(
        rate: Float = 0.5,
        pitchMultiplier: Float = 1.0,
        postUtteranceDelay: Double = 1.0,
        volume: Float = 1.0,
        voice: Voice = .siri_Aaron
    ) {
        self.rate = rate
        self.pitchMultiplier = pitchMultiplier
        self.postUtteranceDelay = postUtteranceDelay
        self.volume = volume
        self.voice = voice
    }
}
