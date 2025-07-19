//
//  Transcription.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import Speech
import SwiftUI

@Observable
final class SpokenWordTranscriber: Sendable {
    var chatMessages: Binding<[ChatMessage]>
    
    private var inputSequence: AsyncStream<AnalyzerInput>?
    private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
    private var transcriber: SpeechTranscriber?
    private var analzyer: SpeechAnalyzer?
    private var recognizerTask: Task<(), Error>?
    private var speaker: TextSpeaker = .init()
    
    var analyzerFormat: AVAudioFormat?
    
    var converter = BufferConverter()
    var isDownloading: Bool = false
    
    var volatileTranscript: AttributedString = ""
    var finalizedTranscript: AttributedString = ""
    
    static let locale = Locale(
        components: .init(
            languageCode: .english,
            script: nil,
            languageRegion: .unitedStates
        )
    )
    
    
    init(chatMessages: Binding<[ChatMessage]>) {
        self.chatMessages = chatMessages
    }
    
    func setUpTranscriber() async throws {
        transcriber = SpeechTranscriber(
            locale: SpokenWordTranscriber.locale,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )
        
        guard let transcriber
        else { throw TranscriptionError.failedToSetupRecognitionStream }
        analzyer = SpeechAnalyzer(modules: [transcriber])
        
        do {
            try await ensureModel(transcriber: transcriber, locale: SpokenWordTranscriber.locale)
        } catch let error as TranscriptionError {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        self.analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])
        (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        
        guard let inputSequence else { return }
        
        recognizerTask = Task {
            do {
                for try await case let result in transcriber.results {
                    print("text: \(result.text)")
                    let text = result.text
                    if result.isFinal {
                        finalizedTranscript += text
                        volatileTranscript = ""
                    } else {
                        volatileTranscript = text
                        volatileTranscript.foregroundColor = .purple.opacity(0.4)
                    }
                }
                appendFinalTranscription(finalizedTranscript)
                finalizedTranscript = ""
            } catch {
                print("speech Recognition failed")
            }
        }
        
        try await analzyer?.start(inputSequence: inputSequence)
    }
    
    func appendFinalTranscription(_ text: AttributedString) {
        let englishText = String(text.characters)
        Task {
            let message = await ChatMessage(
                sender: .user,
                text: englishText,
                timestamp: Date()
            )
            
            await MainActor.run {
                chatMessages.wrappedValue.append(message)
            }
        }
    }
    
    func streamAudioToTranscriber(_ buffer: AVAudioPCMBuffer) async throws {
        guard let inputBuilder,
              let analyzerFormat
        else { throw TranscriptionError.invalidAudioDataType }
        let converted = try self.converter.convertBuffer(buffer, to: analyzerFormat)
        let input = AnalyzerInput(buffer: converted)
        
        inputBuilder.yield(input)
    }
    
    public func finishTranscribing() async throws {
        inputBuilder?.finish()
        try await analzyer?.finalizeAndFinishThroughEndOfInput()
        recognizerTask?.cancel()
        recognizerTask = nil
    }
}


extension SpokenWordTranscriber {
    public func ensureModel(transcriber: SpeechTranscriber, locale: Locale) async throws {
        guard await supported(locale: locale)
        else { throw TranscriptionError.localeNotSupported }
        
        if await installed(locale: locale) { return }
        else { try await downloadIfNeeded(for: transcriber) }
    }
    
    /// 기기가 이 locale(언어)에 대해 음성 인식을 지원하는지 확인
    func supported(locale: Locale) async -> Bool {
        let supported = await SpeechTranscriber.supportedLocales
        return supported.map { $0.identifier(.bcp47) }.contains(locale.identifier(.bcp47))
    }
    
    /// 해당 locale에 대한 음성 인식 모델이 이미 기기에 설치되어 있는지 확인
    func installed(locale: Locale) async -> Bool {
        let installed = await Set(SpeechTranscriber.installedLocales)
        print(installed.map { $0.identifier(.bcp47) })
        return installed.map { $0.identifier(.bcp47) }.contains(locale.identifier(.bcp47))
    }
    
    /// 음성 인식 모듈에 필요한 리소스가 설치되어 있는지 확인 (그렇지 않다면 자동으로 다운로드 시도)
    func downloadIfNeeded(for module: SpeechTranscriber) async throws {
        if let downloader = try await AssetInventory.assetInstallationRequest(supporting: [module]) {
            await MainActor.run {
                isDownloading = true
            }
            try await downloader.downloadAndInstall()
            await MainActor.run {
                isDownloading = false
            }
        }
    }
    
    func deallocate() async {
        let allocated = await AssetInventory.allocatedLocales
        for locale in allocated {
            await AssetInventory.deallocate(locale: locale)
        }
    }
}

