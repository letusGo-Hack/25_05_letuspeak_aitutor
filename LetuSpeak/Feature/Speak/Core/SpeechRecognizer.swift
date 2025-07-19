//
//  SpeechRecognizer.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import Foundation
import AVFoundation
import SwiftUI

class Recorder {
    private var outputContinuation: AsyncStream<AVAudioPCMBuffer>.Continuation? = nil
    private let audioEngine: AVAudioEngine
    private let transcriber: SpokenWordTranscriber
    var playerNode: AVAudioNode?
    
    var chatMessages: Binding<[ChatMessage]>
    
    var file: AVAudioFile?
    
    init(transcriber: SpokenWordTranscriber, chatMessages: Binding<[ChatMessage]>) {
        audioEngine = AVAudioEngine()
        self.transcriber = transcriber
        self.chatMessages = chatMessages
    }
    
    func startLiveTranscription() async throws {
        guard await isAuthorized()
        else { return }
        #if os(iOS)
//        try setUpAudioSession()
        #endif
        
        try await transcriber.setUpTranscriber()
        
        for await input in try await audioStream() {
            try await self.transcriber.streamAudioToTranscriber(input)
        }
    }
    
    func stopTranscription() async throws {
        audioEngine.stop()
        
        try await transcriber.finishTranscribing()
    }
    
    func pauseTranscription() {
        audioEngine.pause()
    }
    
    func resumeTranscription() throws {
        try audioEngine.start()
    }
    
    private func audioStream() async throws -> AsyncStream<AVAudioPCMBuffer> {
        setupAudioEngine()
        
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: audioEngine.inputNode.outputFormat(forBus: 0),
            block: { [weak self] (buffer, _) in
                self?.outputContinuation?.yield(buffer)
            }
        )
        
        audioEngine.prepare()
        try audioEngine.start()
        
        return AsyncStream(AVAudioPCMBuffer.self, bufferingPolicy: .unbounded) { continuation in
            self.outputContinuation = continuation
        }
    }
    
    private func setupAudioEngine() {
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    #if os(iOS)
    func setUpAudioSession() throws {
        let audiosSession = AVAudioSession.sharedInstance()
        try audiosSession.setCategory(.playAndRecord, mode: .spokenAudio)
        try audiosSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    #endif
}
