//
//  Transcription.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import FoundationModels
import Speech
import SwiftUI

@Observable
final class SpokenWordTranscriber: Sendable {
    private var inputSequence: AsyncStream<AnalyzerInput>?
    private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
    private var transcriber: SpeechTranscriber?
    private var analzyer: SpeechAnalyzer?
    private var recognizerTask: Task<(), Error>?
    
    var analyzerFormat: AVAudioFormat?
    
    var volatileTranscript: AttributedString = ""
    var finalizedTranscript: AttributedString = ""
    
    static let locale = Locale(components: .init(languageCode: .english, script: nil, languageRegion: .unitedStates))
    
    
    init() {
        
    }
    
    func setUpTranscriber() async throws {
        transcriber = SpeechTranscriber(
            locale: Locale.current,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )
    }
}
