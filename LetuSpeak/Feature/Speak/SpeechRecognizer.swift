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
    var playerNode: AVAudioNode?
    
    var file: AVAudioFile?
    
    init() {
        audioEngine = AVAudioEngine()
    }
    
    func startLiveTranscription() async throws {
        guard await isAuthorized()
        else { return }
        #if os(iOS)
        try setUpAudioSession()
        #endif
        
        for await input in try await audioStream() {
            
        }
    }
    
    func stopTranscription() {
        audioEngine.stop()
    
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
    private func setUpAudioSession() throws {
        let audiosSession = AVAudioSession.sharedInstance()
        try audiosSession.setCategory(.playAndRecord, mode: .spokenAudio)
        try audiosSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    #endif
}
